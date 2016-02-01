class Layer3Interface::IPv4
  attr_reader :ip_address
  attr_reader :l2_interface
  attr_reader :arp_service
  attr_reader :ipv4_service
  attr_accessor :subnet_mask_size

  def initialize(host:, ip_address:, l2_interface:)
    @host = host
    @arp_service = ArpService.new(host)
    @ipv4_service = IPv4Service.new(host)
    @l2_interface = l2_interface
    @ip_address = ip_address
  end

  def ipv4_packet_out(ip_packet)
    ip_packet.from_ip = @ip_address
    Log.puts "#{@host.name}/#{@name} sending #{ip_packet}" if @trace
    ethernet_packet = encapsulate(ip_packet)
    l2_interface.packet_out ethernet_packet
  end

  private

  def encapsulate(ip_packet)
    Layer2Packet.new(
      to_mac: lookup_mac_address(ip_packet.to_ip),
      payload: ip_packet,
      protocol: :ipv4
    )
  end

  def lookup_mac_address(ip_addr)
    @arp_service.lookup(ip_addr) { |mac_addr| return mac_addr }
  end

end
