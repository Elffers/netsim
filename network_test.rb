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

    # IP address assignment
    # Here, the address are being statically assigned. In most local networks,
    # these are automatically assigned by the DHCP server.
    #
    # NOTE: adding the ipv4 interface is necessary to register any protocol handlers
    @host1.add_ipv4_interface(ip_address: "1.2.3.4", l2_interface: @host1.l2_interfaces.first)
    @host2.add_ipv4_interface(ip_address: "1.2.3.5", l2_interface: @host2.l2_interfaces.first)

    @host1.l2_interfaces[0].connect_to(@switch.l2_interfaces[0])
    @host2.l2_interfaces[0].connect_to(@switch.l2_interfaces[1])
    @host3.l2_interfaces[0].connect_to(@switch.l2_interfaces[2])

  end

  def teardown
    sleep 0.1
  end

  def test_layer2_packet_out
    Log.puts "--- send"

    test1 = TestService.new(@host1)
    test2 = TestService.new(@host2)
    # promiscuous mode allows the host to process any inbound packet
    @host3.l2_interfaces[0].promiscuous = true

    # Host 1 is sending a packet to host 2
    # This packet should be dropped because the switch doesn't know where to
    # send it, but it learns host1's mac address.
    packet = Layer2Packet.new(
      to_mac: @host2.l2_interfaces[0].mac_address,
      payload: "1 to 2",
      protocol: :test
    )
    @host1.l2_interfaces[0].packet_out(packet)

    Thread.pass

    # This is the first packet that should be successfully received because the
    # switch knows where to send packets destined for host1
    packet = Layer2Packet.new(
      to_mac: @host1.l2_interfaces[0].mac_address,
      payload: "2 to 1",
      protocol: :test
    )
    @host2.l2_interfaces[0].packet_out(packet)

    Thread.pass

    # Host1 sending a packet to host2 should succeed
    packet = Layer2Packet.new(
      to_mac: @host2.l2_interfaces[0].mac_address,
      payload: "1 to 2",
      protocol: :test
    )
    @host1.l2_interfaces[0].packet_out(packet)

    Thread.pass

    # Host2 sending a packet to host1 should succeed
    packet = Layer2Packet.new(
      to_mac: @host1.l2_interfaces[0].mac_address,
      payload: "2 to 1",
      protocol: :test
    )
    @host2.l2_interfaces[0].packet_out(packet)

    Thread.pass

    sleep 0.1

    assert_equal 2, test1.packets.length, "host1 test service"
    assert_equal 1, test2.packets.length, "host2 test service"
  end

  def test_broadcast
    Log.puts "--- broadcast"

    test = TestService.new(@host2)

    packet = Layer2Packet.new(
      to_mac: MacAddress::BROADCAST,
      payload: "hello everyone",
      protocol: :test)
    @host1.l2_interfaces[0].packet_out(packet)

    sleep 0.1

    assert_equal 1, test.packets.length, "Broadcast packet received"
  end

  def test_ipv4address_network_addr
    a = IPv4Address.new("1.2.3.4")

    assert_equal 4, a.host_addr(24), "Network address"
  end

  def test_ipv4address_host_addr
    a = IPv4Address.new("1.2.3.4")

    assert_equal 4, a.host_addr(24), "Host address"
  end

  def test_arp_lookup
    Log.puts "--- arp"
    arp1 = @host1.l3_interfaces.first.arp_service
    arp1.lookup(@host2.ip_address) do |mac|
      assert_equal @host2.mac_address, mac
    end
  end

  def test_add_ipv4_interface
    assert_equal "1.2.3.4", @host1.ip_address
  end

  def test_ipv4_packet_out
    Log.puts "--- ip send"

    l2_interface = Layer2Interface::Test.new
    l3_interface = Layer3Interface::IPv4.new(
      host: @host1,
      ip_address: '1.2.3.4',
      l2_interface: l2_interface
    )

    packet = Layer3Packet.new(
      to_ip: @host2.ip_address,
      payload: "hey ho")

    l3_interface.packet_out(packet)

    assert_equal 1, l2_interface.packets.count
    assert_equal '1.2.3.4', packet.from_ip
  end

end
