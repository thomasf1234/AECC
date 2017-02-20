require 'socket'
require 'json'
require_relative 'application'

require 'sinatra'

PORT = 3000

ip = Socket.ip_address_list.detect{|intf| intf.ipv4_private?}
ip_port = "#{ip.ip_address}:#{PORT}"

puts "################"
puts AECC::Utils.margin("GET #{ip_port}/healthcheck", 'Check Server Running')
puts AECC::Utils.margin("GET #{ip_port}/database/running_emulators", 'Check database')
puts AECC::Utils.margin("GET #{ip_port}/avds", 'List avds')
puts AECC::Utils.margin("GET #{ip_port}/avds/:avd_name/start", 'Start emulator')
puts AECC::Utils.margin("GET #{ip_port}/emulators/kill", 'Kill all detectable emulators')
puts AECC::Utils.margin("GET #{ip_port}/emulators/:uuid/kill", 'Kill emulator')
puts AECC::Utils.margin("POST #{ip_port}/emulators/:uuid/packages", 'Deploy package')
puts AECC::Utils.margin("GET #{ip_port}/emulators/:uuid/packages/:package/reset_permissions", 'Reset permissions')
puts "################"

set :bind, '0.0.0.0'
set :port, PORT

configure do
  AECC::DB.init
end

get '/healthcheck' do
  'Sinatra Server AndroidEmulatorControlCentre is running'
end

get '/database/running_emulators' do
  AECC::DB.instance.running_emulators.all.map(&:to_json)
end


get '/avds' do
  AECC::System.instance.terminal.emulator("-list-avds")
end

get '/avds/:avd_name/start' do
  content_type :json
  device =  AECC::System.instance.start_emulator(params['avd_name'])
  device.uuid
end

get '/emulators/kill' do
  AECC::System.instance.kill_all_emulators
  "Killed"
end

get '/emulators/:uuid/kill' do
  #must wait until actual dead
  AECC::System.instance.kill(params['uuid'])
  "Killed #{params['uuid']}"
end

#curl -F "data=@myowndiary.apk" 10.32.10.17:3000/emulator/running/e83c515-3af0-458a-a01a-129ad6cd74c0/deploy
post '/emulators/:uuid/packages' do
  device = AECC::Device.find(params['uuid'])

  APK_UPLOAD_PATH = 'tmp/uploads/apk'
  FileUtils.mkdir_p(APK_UPLOAD_PATH)

  apk_path = File.join(APK_UPLOAD_PATH, params['data'][:filename])
  File.open(apk_path, "w") do |file|
    file.write(params['data'][:tempfile].read)
  end
  apk = AECC::ApkFactory.build(apk_path)
  remote_apk_path = device.push(apk)
  device.install(remote_apk_path)

  {path: apk.path, package: apk.package, launchable_activity: apk.launchable_activity}.to_json
end

get '/emulators/:uuid/packages/:package/reset_permissions' do
  device = AECC::Device.find(params['uuid'])
  permissions = device.permissions(params['package'])
  granted_permissions = permissions.select(&:granted?)

  granted_permissions.each do |permission|
    device.revoke_permission(params['package'], permission)
  end

  "Revoked permissions for (#{granted_permissions.map(&:name).join(', ')})"
end



# curl 10.32.10.17:3000/emulator/Nexus_6_API_24/start
# curl -F "data=@myowndiary.apk" 10.32.10.17:3000/emulator/running/b45cfb29-0ec7-4682-93a0-7f6cf2c7d5cc/deploy
# curl 10.32.10.17:3000/emulator/running/8070ad4e-3048-499b-814d-9273b9399fef/package/com.abstractx1.mydiary/reset_permissions
