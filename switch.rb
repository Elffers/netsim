# A switch is a device with multiple interfaces that interconnects other
# devices. In real life this would be a box with many Ethernet ports, or
# a virtual device with many virtual interfaces.
#
# Switches don't generally echo incoming packets out of all the ports on the
# switch (except, of course, for broadcast packets). Instead, they "learn" what
# MAC addresses are visible on each port by examining incoming packets, and
# forward packets only to the port that is known to correspond to an incoming
# packet's "to" address.
#
class Switch < Host
  attr_reader :ports

  def initialize(name, num_ports)
    super
    @mutex = Mutex.new
    @interfaces.each { |intf| intf.promiscuous = true }
    @mac_map = {}
  end

  def handle_packet(interface, packet)
    # "Learn" that this MAC address is on this interface.
    @mutex.synchronize do
      Log.puts "Learning #{packet.from_mac} on #{interface.name}" unless @mac_map[packet.from_mac]
      @mac_map[packet.from_mac] = interface
    end

    if packet.to_mac == MacAddress::BROADCAST
      # Broadcast packets go back out to all interfaces except the one they
      # came in on.
      @interfaces.each_with_index do |out_port, i|
        if out_port != interface
          out_port.packet_out(packet)
        end
      end
    else
      # Unicast packets only go out the port for the destination host (if we've
      # heard of this address before).
      out_port = @mutex.synchronize { @mac_map[packet.to_mac] }
      if out_port
        out_port.packet_out(packet)
      else
        Log.puts "#{name} dropped #{packet}"
      end
    end
  end
end
