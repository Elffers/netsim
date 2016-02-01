require 'agent'
require 'pry'
Thread.abort_on_exception = true

module Layer2Interface end
module Layer3Interface end
require_relative 'arp_payload'
require_relative 'arp_service'
require_relative 'host'
require_relative 'ethernet'
require_relative 'ipv4_address'
require_relative 'ipv4_interface'
require_relative 'layer2_packet'
require_relative 'layer3_packet'
require_relative 'mac_address'
require_relative 'switch'
require_relative 'log'
require_relative 'test_service'

Log.puts "Log started"
