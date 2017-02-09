require 'singleton'
require 'securerandom'
require_relative 'device'
require_relative '../../lib/log_file'
require_relative '../terminal'

# https://github.com/jackpal/Android-Terminal-Emulator/wiki/Android-Shell-Command-Reference
class System
  include Singleton
  DEFAULT_ANDROID_SDK_HOME = '/usr/lib/android-sdk'
  ANDROID_SERIAL_IDENTIFIER_REGEX = /emulator-\d+/
  DEVICE_BOOTED_IDENTIFIER = '1'

  def initialize
    @terminal = Terminal.new
  end

  def terminal
    @terminal
  end

  def deploy(apk, device)
    remote_path = device.push(apk)
    device.install(remote_path)
  end

  #Change to find Device.find_by(android_serial)
  def kill_all_emulators
    android_serials = terminal.adb("devices").scan(/emulator-\d+/)

    android_serials.each do |android_serial|
      terminal.adb("-s #{android_serial} emu kill")
    end
  end

  def start_emulator(avd_name)
    #must ensure adb server is running
    # Logger.instance.log("#Starting emulator")
    #must lock the port
    port = Device.allowed_ports.detect(&:free?)

    if port.nil?
      raise "No free ports available"
    else
      ALogger.instance.log("#starting emulator avd #{avd_name}")
      #TODO : get PID
      terminal.emulator("-wipe-data -no-boot-anim -shell -netdelay none -netspeed full -port #{port.number} -avd #{avd_name} > log/#{avd_name}.log &")

      android_serial = Utils.retry_block(5, 10) do
        ALogger.instance.log("#attempting to find android-serial on port #{port.number}")
        android_serials = @terminal.adb("devices").scan(ANDROID_SERIAL_IDENTIFIER_REGEX)

        if(android_serials.empty?)
          ALogger.instance.puts("raising: No device not found")
          raise 'No device not found'
        else
          android_serial = android_serials.detect do |android_serial|
            !android_serial.match(/#{port.number}/).nil?
          end

          if android_serial.nil?
            ALogger.instance.log("raising: Device with port '#{port.number}' not found")
            raise "Device with port '#{port.number}' not found"
          else
            android_serial
          end
        end
      end
    end

    ALogger.instance.log("#waiting for device to come online")
    @terminal.adb("-s #{android_serial} wait-for-device")

    #Add timeout in case device does not boot
    device_booted = false
    until (device_booted)
      ALogger.instance.log("#waiting for device to boot")
      device_booted = terminal.adb("-s #{android_serial} shell getprop sys.boot_completed").include?(DEVICE_BOOTED_IDENTIFIER)
      Utils.wait(1)
    end

    ALogger.instance.log("#Hurray! Device booted successfully")

    device = Device.new(avd_name, android_serial, port)

    Utils.wait(5)

    device.assign_uuid(SecureRandom.uuid)

    ALogger.instance.log("#Pressing home on device")
    device.press_home
    device
  end
end