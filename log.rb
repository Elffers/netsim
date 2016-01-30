module Log
  LOG_CHAN = begin
    chan = Agent.channel!(String, name: "log")
    go! { loop { print chan.receive.first }}
    chan.as_send_only
  end

  module_function

  def puts(msg)
    LOG_CHAN << (msg.to_s + "\n")
  end

  def write(msg)
    LOG_CHAN << msg
  end
end
