# A switch is a device with multiple interfaces that interconnects other
# devices. In real life this would be a box with many Ethernet ports, or
# a virtual device with many virtual interfaces.
#
# Switches don't generally echo incoming packets out of all the ports on the
# switch (except, of course, for broadcast packets). Instead, they "learn" what
# MAC addresses are visible on each port by examining incoming packets, and
# forward packets only to the port that is known to correspond to an incoming
# packet's "to" address. (Difference between switch and hub is that a hub
# forwards all packets along to all hosts)
#
#
# (Analogy: local post office, or front desk at an office that handles
# forwarding calls onto extensions)
#
# Physical switches (or hubs) are only needed for wired ethernet networks.
# Wi-fi networks do not need switches bc the wireless protocol already sort of
# takes care of the job the switch does of interconnecting hosts.

class Switch < Host
  attr_reader :ports

  def initialize(name)
    super
    # TODO: Switch will inherit @l3_interfaces, but shouldn't. Refactor later.
    @mutex = Mutex.new
    @mac_map = {}
  end

  def add_ethernet_interface
    interface = super
    interface.promiscuous = true
    interface
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
      @l2_interfaces.each_with_index do |out_port, i|
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
