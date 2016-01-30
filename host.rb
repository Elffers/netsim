# A host is an active device connected to one or more networks via interfaces.

class Host
  attr_reader :interfaces
  attr_reader :name

  def initialize(name, num_interfaces)
    @name = name
    @interfaces = (0...num_interfaces).map { |i| IPv4Interface.new(self, "eth#{i}") }
    @protocol_handlers = {}
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
