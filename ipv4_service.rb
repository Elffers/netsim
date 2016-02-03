class IPv4Service
  def initialize(host)
    @host = host
    host.register_protocol_handler(:ipv4, self)
  end

  def handle_packet(interface, l2_packet)
    strip_headers(l2_packet)
  end

  private

  def strip_headers(l2_packet)
    l2_packet.payload
  end
end
