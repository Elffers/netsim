# TODO: An ethernet interface is a hardware interface, modeled by the
# Interface class. An IPv4 interface is a software interace that
# allows IPv4 packets to be encapsulated in ethernet packets.
# Therefore it is not really a subclass of an ethernet interface, but
# rather belongs to one.

class IPv4Interface < Interface
  attr_accessor :ip_address
  attr_accessor :subnet_mask_size

  def ip_packet_in(packet)

  end

  def ip_packet_out(packet)

  end
end
