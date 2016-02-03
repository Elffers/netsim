class UDPPacket
  attr_accessor :to_port
  attr_accessor :from_port
  attr_reader :payload

  def initialize(from_port:, to_port:, payload:)
    @from_port = from_port
    @to_port = to_port
    @payload = payload
  end

  def to_s
    "(#{from_port} -> #{to_port} #{payload})"
  end
end
