# A layer 3 packet goes from one interface to another anywhere on the internet.
# Thus, its "from" and "to" addresses are IP addresses.
#
# A layer 3 packet is always "encapsulated" as the payload of a layer 2 packet.
# Otherwise, you wouldn't be able to actually send it anywhere. When a layer
# 3 packet is destined for a layer 2 network other than the one it originates
# on, the same layer 3 payload is encapsulated in many different layer
# 2 packets as it hops through the internet.
#
class Layer3Packet
  attr_accessor :from_ip
  attr_accessor :to_ip
  attr_accessor :payload

  def initialize(from_ip:, to_ip:, payload:)
    @from_ip = from_ip
    @to_ip = to_ip
    @payload = payload
  end

  def to_s
    "(#{from_ip} -> #{to_ip} #{payload})"
  end
end
