# ARP protocol -- RFC826
#
# "The world is a jungle in general, and the networking game
# contributes many animals."
#
class ArpPayload < Struct.new(:operation,
                              :sender_mac,
                              :sender_ip,
                              :target_mac,
                              :target_ip)
  def to_s
    "(#{operation} snd #{sender_mac} #{sender_ip} tgt #{target_mac} #{target_ip})"
  end

  def self.request_packet(sender_mac, sender_ip, target_ip)
    Layer2Packet.new(to_mac: MacAddress::BROADCAST,
                     protocol: :arp,
                     payload: new(:request, sender_mac, sender_ip, nil, target_ip))
  end

  def self.reply_packet(request_packet, sender_mac, sender_ip)
    Layer2Packet.new(to_mac: request_packet.payload.sender_mac,
                     protocol: :arp,
                     payload: new(:reply, sender_mac, sender_ip,
                                  request_packet.payload.sender_mac,
                                  request_packet.payload.sender_ip))
  end
end
