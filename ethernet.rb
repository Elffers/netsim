# An interface is a means of communication between a host and a network. In the
# real world, an interface might be an Ethernet port on a computer. It might
# also be a virtual interface on a virtual machine.
#
# Interfaces are uniquely identified by MAC addresses, and that is how they
# refer to other interfaces when they want to send them packets.
#
class Layer2Interface::Ethernet
  attr_accessor :mac_address
  attr_reader :name
  attr_accessor :promiscuous
  attr_accessor :trace

  def initialize(host, name)
    @host = host
    @name = name
    @mac_address = MacAddress.next
    @trace = false
  end

  # Connect a cable from this interface to another interface.
  #
  def connect_to(other_end)
    @other_end = other_end
    in_chan = Agent.channel!(Layer2Packet, 1000, name: "in_#{@mac_address}")
    out_chan = Agent.channel!(Layer2Packet, 1000, name: "out_#{@mac_address}")

    # This simulates a duplex connection (two interfaces are simulataneously
    # sending and receiving packets)
    connect_channels(in_chan.as_receive_only, out_chan.as_send_only)
    other_end.connect_channels(out_chan.as_receive_only, in_chan.as_send_only)
  end

  # Process an outgoing packet.
  #
  def packet_out(packet)
    packet.from_mac = @mac_address
    Log.puts "#{@host.name}/#{@name} sending #{packet}" if @trace
    @out_chan << packet if @out_chan
  end

  def full_name
    "#{@host.name}/#{@name}"
  end

  def to_s
    "#<Interface #{full_name} #{@mac_address}>"
  end

  protected
  # Actual legit use of protected! Interfaces are only allowed to connect to
  # other interfaces and nothing else.
  def connect_channels(in_chan, out_chan)
    raise "Already connected" if @in_chan
    @in_chan = in_chan
    @out_chan = out_chan
    start_receive_loop
  end

  private

  def start_receive_loop
    go! do
      loop do
        packet, ok = @in_chan.receive
        break unless ok
        packet_in(packet)
      end
    end
  end

  # Process an incoming packet. Normally an interface only pays attention to
  # packets addressed to its own MAC address, or to the broadcast address.
  # However, an interface in "promiscuous mode" will process all packets
  # regardless of "to" address.

  def packet_in(packet)
    if @promiscuous || packet.to_mac == @mac_address || packet.to_mac == MacAddress::BROADCAST
      Log.puts "#{@host.name}/#{@name} got #{packet}" if @trace
      @host.handle_packet(self, packet)
    end
  end

  def add_ip_address(address, subnet_mask_size)

  end
end
