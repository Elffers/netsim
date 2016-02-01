class ArpService
  def initialize(host)
    @host = host
    @cache = {}
    @pending_replies = Hash.new { |h,k| h[k] = [] }
    @mutex = Mutex.new
    host.register_protocol_handler(:arp, self)
  end

  # Synchronous lookup
  #
  def lookup(ip_addr, &block)
    cached_addr = @mutex.synchronize { @cache[ip_addr] }
    if cached_addr
      yield cached_addr
    else
      reply_chan = Agent.channel!(MacAddress, name: "ARP_#{ip_addr}")
      @mutex.synchronize { @pending_replies[ip_addr] << reply_chan }

      @host.l3_interfaces.each do |intf|
        request = ArpPayload.request_packet(intf.l2_interface.mac_address, intf.ip_address, ip_addr)
        intf.l2_interface.packet_out(request.dup)
      end
      select! do |s|
        s.case(reply_chan, :receive) do |mac|
          @mutex.synchronize { @cache[ip_addr] = mac }
          yield mac
        end
        s.timeout(1.0) do
          @mutex.synchronize { @pending_replies[ip_addr].delete(reply_chan) }
          yield :timeout
        end
      end
    end
  end

  def handle_packet(interface, packet)
    arp = packet.payload
    case arp.operation
      when :request
        Log.puts "#{interface.full_name} ARP: looking up #{arp.target_ip}"
        @host.l3_interfaces.each do |intf|
          if intf.ip_address == arp.target_ip
            reply = ArpPayload.reply_packet(packet, intf.l2_interface.mac_address, intf.ip_address)
            interface.packet_out(reply)
          end
        end
      when :reply
        Log.puts "#{interface.full_name} ARP: got reply for #{arp.sender_ip} is at #{arp.sender_mac}"
        reply_chans = @mutex.synchronize { @pending_replies.delete(arp.sender_ip) }
        reply_chans.each { |c| c << arp.sender_mac } if reply_chans
    end
  end

end
