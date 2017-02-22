require 'socket'
require_relative 'application'

require 'sinatra'

PORT = 3000

ip = Socket.ip_address_list.detect{|intf| intf.ipv4_private?}
ip_port = "#{ip.ip_address}:#{PORT}"

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

post '/emulators/start' do
  device =  AECC::System.instance.start_emulator(params['avd_name'])
  device.uuid
end

get '/emulators/kill' do
  AECC::System.instance.kill_all_emulators
  "Killed"
end

post '/emulators/kill' do
  #must wait until actual dead
  AECC::System.instance.kill(params['device_uuid'])
  "Killed #{params['device_uuid']}"
end

post '/emulators/:device_uuid/packages' do
  device = AECC::Device.find(params['device_uuid'])

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

post '/emulators/:device_uuid/packages/:package/permissions' do
  device = AECC::Device.find(params['device_uuid'])

  if params['action'] == 'reset'
    device.reset_permissions(params['package'])
    "Revoked runtime granted permissions"
  end
end

# get '/emulators/:uuid/packages/:package/test/:method' do
#   device = AECC::Device.find(params['uuid'])
#   package = params['package']
#
#   device.force_stop(package)
#   device.reset_permissions(package)
#   device.run_test(tes_package)
#
#   "Revoked permissions for (#{granted_permissions.map(&:name).join(', ')})"
# end



# "CONTENT_TYPE"=>"multipart/form-data; boundary=------------------------a2fffb99f068eb2c"
# {"data"=>
#      {:filename=>"myowndiary.apk",
#       :type=>"application/octet-stream",
#       :name=>"data",
#       :tempfile=>#<File:/var/folders/pv/4c69gvs91d719y5hpsrsrnt8vcjhs5/T/RackMultipart20170221-1475-1kh5yhd.apk>,
#           :head=>"Content-Disposition: form-data; name=\"data\"; filename=\"myowndiary.apk\"\r\nContent-Type: application/octet-stream\r\n"}},
# curl 10.32.10.17:3000/emulator/Nexus_6_API_24/start
# curl -F "data=@myowndiary.apk" 10.32.10.17:3000/emulator/running/b45cfb29-0ec7-4682-93a0-7f6cf2c7d5cc/deploy
# curl 10.32.10.17:3000/emulator/running/8070ad4e-3048-499b-814d-9273b9399fef/package/com.abstractx1.mydiary/reset_permissions
