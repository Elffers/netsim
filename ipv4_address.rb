# An IP address identifies an interface anywhere on the internet. It has two
# parts: the "network address" (sometimes called the "subnet"), which
# identifies the (layer 2) network the interface resides on, and the "host
# address", which identifies the interface within that network.
#
# IPv4 addresses are four bytes long, usually written as one decimal number per
# byte, separated by dots.
#
# Note that the form of an IP address is completely different from that of
# a MAC address. Internet-level addressing (layer 3) is abstracted from the
# various types of addressing used by individual networks.
#
# The split between network and host addresses is variable in size and defined
# for each individual network. The global address space is parceled out into
# non-overlapping subnets by various authorities, ending with the local network
# administrator. Because an IP address doesn't inherently provide this
# information, addresses are often written in "CIDR format" with a suffix
# giving the size of the network address in bits. For example, looking at the
# address 216.122.19.4 doesn't tell you that the network address is the left 26
# bits (network 216.122.19.0, host 4), but the notation 216.122.19.4/26 does.
#
class IPv4Address
  attr_accessor :word

  def initialize(dotted = "0.0.0.0")
    bytes = dotted.split(".")

    # Unpacking with N guarantees big-endianness, which is the network byte
    # order
    @word = bytes.map(&:to_i).pack("CCCC").unpack("N").first
  end

  def ==(rhs)
    @word == rhs.word
  end
  alias :eql? :==

  def hash
    @word.hash
  end

  def network_addr(mask_size)
    addr = IPv4Address.new
    # -1 is always all ones in 2's-complement int representation
    addr.word = @word & (-1 << (32 - mask_size))
    addr
  end

  def host_addr(mask_size)
    @word & ~(-1 << (32 - mask_size))
  end

  def to_s
    [@word].pack("N").unpack("CCCC").map(&:to_s).join(".")
  end
end

