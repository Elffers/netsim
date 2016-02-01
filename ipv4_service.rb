class IPv4Service
  def initialize(host)
    @host = host
    host.register_protocol_handler(:ipv4, self)
  end

  def handle_packet(interface, l2_packet)
    ip_packet = strip_headers(l2_packet)
  end

  def strip_headers(l2_packet)
    l2_packet.payload
  end
end
