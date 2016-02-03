class Layer4Interface::UDPSocket
  attr_accessor :to_port, :from_port

  def initialize(l3_interface:, to_port:, from_port:, to_ip:)
    @l3_interface  = l3_interface
    @to_port       = to_port
    @from_port     = from_port
    @trace         = false
    @to_ip         = to_ip
  end

  def packet_out(payload)
    udp_packet = UDPPacket.new(
      from_port: from_port,
      to_port: to_port,
      payload: payload)

    Log.puts "#{@l3_interface.host.name}/#{@name} sending #{packet}" if @trace

    ip_packet = encapsulate(udp_packet)
    @l3_interface.packet_out ip_packet
  end

  def encapsulate(udp_packet)
    Layer3Packet.new(
      to_ip: @to_ip,
      payload: udp_packet)
  end
end
