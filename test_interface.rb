class Layer2Interface::Test
  attr_reader :packets

  def initialize
    @packets = []
  end

  def packet_out(packet)
    packets << packet
  end
end
