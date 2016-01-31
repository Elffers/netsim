# A host is an active device connected to one or more networks via interfaces.

class Host
  attr_reader :name
  attr_reader :l2_interfaces
  attr_reader :l3_interfaces

  def initialize(name)
    @name = name
    @protocol_handlers = {}
    @l2_interfaces = []
    @l3_interfaces = []
  end

  def add_ethernet_interface
    @l2_interfaces << Layer2Interface::Ethernet.new(self, "eth#{l2_interfaces.size}")
  end

  def add_ipv4_interface(l2_interface:, ip_address:)
    @l3_interfaces <<
    Layer3Interface::IPv4.new(
      host: self,
      ip_address: ip_address,
      l2_interface: l2_interface)
  end

  def register_protocol_handler(protocol_name, handler)
    @protocol_handlers[protocol_name] = handler
  end

  def handle_packet(interface, packet)
    handler = @protocol_handlers[packet.protocol]
    if handler
      begin
        handler.handle_packet(interface, packet)
      rescue StandardError => e
        Log.puts "Packet handler failed: #{e}\n#{e.backtrace.join("\n")}"
      end
    else
      Log.puts "#{name} can't handle #{packet}"
    end
  end

  def to_s
    "#<Host #{name}>"
  end
end
