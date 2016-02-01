class TestService
  attr_reader :packets

  def initialize(host)
    @host = host
    @packets = []
    host.register_protocol_handler(:test, self)
  end

  def handle_packet(interface, packet)
    packets << packet
  end
end
