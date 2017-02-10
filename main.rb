require 'socket'
require 'sinatra'
require 'json'
require_relative 'application'

PORT = 3000

ip = Socket.ip_address_list.detect{|intf| intf.ipv4_private?}
ip_port = "#{ip.ip_address}:#{PORT}"

puts "################"
puts "Check Server Running at #{ip_port}/healthcheck"
puts "Start emulator at #{ip_port}/emulator/:avd_name/start"
puts "Kill all detectable emulators at #{ip_port}/emulator/kill_all"
puts "################"

set :bind, '0.0.0.0'
set :port, PORT

get '/healthcheck' do
  'Sinatra Server AndroidEmulatorControlCentre is running'
end

get '/emulator/list_avds' do
  System.instance.terminal.emulator("-list-avds")
end

get '/emulator/:avd_name/start' do
  content_type :json
  device = System.instance.start_emulator(params['avd_name'])
  { :avd_name => device.avd_name, :serial_number => device.serial_number, :port => device.port.number, :uuid => device.uuid }.to_json
end

get '/emulator/kill_all' do
  System.instance.kill_all_emulators
end


# res = System.instance.terminal.aapt("dump badging deployment/test/samples/apk/test.apk")

#apk = Apk.new("deployment/test/samples/apk/test.apk")
# emulator = Device.new('Nexus_6_API_24', 'emulator-5554', 5554)
# puts apk.inspect
#remote_path = emulator.push(apk)
#emulator.install(remote_path)
# emulator.force_stop(apk.package)
# emulator.uninstall(apk.package)


#System.instance.deploy(apk, device)
#device.press_back

#puts "exiting"

# log = LogFile.new('System')
# terminal = Terminal.new(log, {'ANDROID_SDK_HOME' => '/Users/tfisher/Library/Android/sdk'})
#
# apk = Apk.new(terminal, "/Users/tfisher/AndroidStudioProjects/ProjectManagement/app/build/outputs/apk/app-debug-androidTest.apk")
#
# puts apk.path
# puts apk.package
# puts apk.launchable_activity
#
#
# emulator = System.new(terminal).start_emulator('Nexus_6_API_23')
# log.close

