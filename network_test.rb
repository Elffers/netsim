require_relative "netstuff"
require "minitest/autorun"

class NetworkTest < Minitest::Test

  def setup
    @switch = Switch.new("switch1")
    # Add the number of ports manually
    @switch.add_ethernet_interface
    @switch.add_ethernet_interface
    @switch.add_ethernet_interface
    @switch.add_ethernet_interface

    @host1 = Host.new("host1")
    @host2 = Host.new("host2")
    @host3 = Host.new("host3")

    # Physical connections (wires)
    @host1.add_ethernet_interface
    @host2.add_ethernet_interface
    @host3.add_ethernet_interface

    @host1.l2_interfaces[0].connect_to(@switch.l2_interfaces[0])
    @host2.l2_interfaces[0].connect_to(@switch.l2_interfaces[1])
    @host3.l2_interfaces[0].connect_to(@switch.l2_interfaces[2])

    # IP address assignment
    # Here, the address are being statically assigned. In most local networks,
    # these are automatically assigned by the DHCP server.
    @host1.add_ipv4_interface(ip_address: "1.2.3.4", l2_interface: @host1.l2_interfaces.first)
    @host2.add_ipv4_interface(ip_address: "1.2.3.5", l2_interface: @host2.l2_interfaces.first)
  end

  def teardown
    sleep 0.1
  end

  def test_send
    Log.puts "--- send"

    # promiscuous mode allows the host to process any inbound packet
    @host3.l2_interfaces[0].promiscuous = true
    # Host 1 is sending a packet to host 2
    packet = Layer2Packet.new(to_mac: @host2.l2_interfaces[0].mac_address, payload: "1 to 2")
    @host1.l2_interfaces[0].packet_out(packet)

    sleep 0.1

    packet = Layer2Packet.new(to_mac: @host1.l2_interfaces[0].mac_address, payload: "2 to 1")
    @host2.l2_interfaces[0].packet_out(packet)
    packet = Layer2Packet.new(to_mac: @host2.l2_interfaces[0].mac_address, payload: "1 to 2")
    @host1.l2_interfaces[0].packet_out(packet)
    packet = Layer2Packet.new(to_mac: @host1.l2_interfaces[0].mac_address, payload: "2 to 1")
    @host2.l2_interfaces[0].packet_out(packet)
  end

  def test_broadcast
    Log.puts "--- broadcast"

    packet = Layer2Packet.new(to_mac: MacAddress::BROADCAST, payload: "hello everyone")
    @host1.l2_interfaces[0].packet_out(packet)
  end

  def test_ipv4address
    a = IPv4Address.new("1.2.3.4")
    assert_equal "1.2.3.0", a.network_addr(24).to_s
    assert_equal 4, a.host_addr(24)
  end

  def test_arp
    Log.puts "--- arp"
    arp1 = ArpService.new(@host1)
    arp2 = ArpService.new(@host2)
    arp1.lookup(@host2_ip) { |mac| Log.puts ">>> #{mac}" }
  end

  def test_ip_send
    Log.puts "--- ip send"
    packet = Layer3Packet.new(from_ip: @host1_ip, to_ip: @host2_ip, payload: "hey ho")
    @host1.l3_interfaces[0].ipv4_packet_out(packet)
  end
end
