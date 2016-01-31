# TODO: An ethernet interface is a hardware interface, modeled by the
# Interface class. An IPv4 interface is a software interace that
# allows IPv4 packets to be encapsulated in ethernet packets.
# Therefore it is not really a subclass of an ethernet interface, but
# rather belongs to one.
#
# TODO: Build IPService to match ArpService for unpacking a Layer3Packet

class IPv4Interface < Interface
  attr_accessor :ip_address
  attr_accessor :subnet_mask_size

  def initialize(*)
    super
    @arp_service = ArpService.new(@host)
  end

  def ipv4_packet_in(ip_packet)
    ethernet_packet = strip_headers ip_packet
    packet_in ethernet_packet
  end

  def ipv4_packet_out(ip_packet)
    ip_packet.from_ip = @ip_address
    Log.puts "#{@host.name}/#{@name} sending #{ip_packet}" if @trace
    ethernet_packet = encapsulate(ip_packet)
    packet_out ethernet_packet
  end

  private

  def encapsulate(ip_packet)
    Layer2Packet.new(
      to_mac: lookup_mac_address(ip_packet.to_ip),
      payload: ip_packet
    )
  end

  def lookup_mac_address(ip_addr)
    @arp_service.lookup(ip_addr) { |mac_addr| return mac_addr }
  end

  def strip_headers ip_packet
  end
end
