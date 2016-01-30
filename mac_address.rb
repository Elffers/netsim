# A MAC (media access control) address uniquely identifies an interface on
# a network (actually, it's globally unique).  Conversely, a network is
# a collection of hosts that can communicate with each other using their
# interfaces' MAC addresses for addressing.

class MacAddress
  attr_reader :bytes

  @mutex = Mutex.new
  @next_mac = 0

  def initialize(bytes)
    raise "6 bytes please" unless bytes.length == 6
    @bytes = bytes
  end

  def ==(rhs)
    @bytes == rhs.bytes
  end
  alias :eql? :==

  def hash
    @bytes.hash
  end

  def to_s
    @bytes.unpack("H*")[0].scan(/../).join(":")
  end

  # The all-ones address is the broadcast address (by definition)
  BROADCAST = new("\xff\xff\xff\xff\xff\xff")

  def self.next
    @mutex.synchronize do
      @next_mac += 1
      # packs the mac_address into hex format
      new([@next_mac].pack("xxl>"))
    end
  end

  def self.random
    new(Random.new.bytes(6))
  end
end

