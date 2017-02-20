require 'socket'
require 'json'
require_relative 'application'

require 'sinatra'

PORT = 3000

ip = Socket.ip_address_list.detect{|intf| intf.ipv4_private?}
ip_port = "#{ip.ip_address}:#{PORT}"

puts "################"
puts AECC::Utils.margin("#{ip_port}/healthcheck", 'Check Server Running')
puts AECC::Utils.margin("#{ip_port}/database/running_emulators/all", 'Check database')
puts AECC::Utils.margin("#{ip_port}/emulator/list_avds", 'List avds')
puts AECC::Utils.margin("#{ip_port}/emulator/:avd_name/start", 'Start emulator')
puts AECC::Utils.margin("#{ip_port}/emulator/kill_all", 'Kill all detectable emulators')
puts AECC::Utils.margin("#{ip_port}/emulator/running/:uuid/kill", 'Kill emulator')
puts "################"

set :bind, '0.0.0.0'
set :port, PORT

configure do
  AECC::DB.init
end

get '/healthcheck' do
  'Sinatra Server AndroidEmulatorControlCentre is running'
end

get '/database/running_emulators/all' do
  AECC::DB.instance.running_emulators.all.map(&:to_json)
end


get '/emulator/list_avds' do
  AECC::System.instance.terminal.emulator("-list-avds")
end

get '/emulator/:avd_name/start' do
  content_type :json
  device =  AECC::System.instance.start_emulator(params['avd_name'])
  device.uuid
end

get '/emulator/running/kill_all' do
  AECC::System.instance.kill_all_emulators
  "Killed"
end

get '/emulator/running/:uuid/kill' do
  AECC::System.instance.kill(params['uuid'])
  "Killed #{params['uuid']}"
end


