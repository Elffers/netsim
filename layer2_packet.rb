# A layer 2 packet is sent directly from one interface to another on
# a network. Thus, MAC addresses are used as the "from" and "to" fields.
#
# Each packet specifies a "protocol" that identifies what kind of packet it is,
# and thus what kind of payload it has.
#
class Layer2Packet
  attr_accessor :from_mac
  attr_accessor :to_mac
  attr_accessor :payload
  attr_accessor :protocol

  def initialize(to_mac:, protocol: :none, payload:)
    @to_mac = to_mac
    @protocol = protocol
    @payload = payload
  end

  def to_s
    "[#{protocol} (#{from_mac} -> #{to_mac}) #{payload}]"
  end
end
