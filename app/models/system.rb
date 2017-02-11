require 'singleton'
require 'securerandom'
require_relative 'device'
require_relative '../../lib/log_file'
require_relative '../models/terminal'
require 'set'

# https://github.com/jackpal/Android-Terminal-Emulator/wiki/Android-Shell-Command-Reference
module AECC
  class System
    include Singleton
    DEFAULT_ANDROID_SDK_HOME = '/usr/lib/android-sdk'
    ANDROID_SERIAL_IDENTIFIER_REGEX = /emulator-\d+/
    DEVICE_BOOTED_IDENTIFIER = '1'

    def initialize
      @terminal = AECC::Terminal.new
      @used_ports = Set.new
    end

    def terminal
      @terminal
    end

    def clear_used_ports
      @used_ports.clear
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

      #TODO : must check here that all ports are cleared
      clear_used_ports
    end

    def start_emulator(avd_name)
      #must ensure adb server is running
      # Logger.instance.log("#Starting emulator")
      #must lock the port

      #this all needs to be synchronized call
      port = AECC::Device.allowed_ports.detect do |port|
        !@used_ports.include?(port.number) && port.free?
      end

      #maybe remove lock after instantiating device class
      @used_ports.add(port.number)

      if port.nil?
        raise "No free ports available"
      else
        AECC::Logger.instance.log("#starting emulator avd #{avd_name}")
        #TODO : get PID
        terminal.emulator("-wipe-data -no-boot-anim -shell -netdelay none -netspeed full -port #{port.number} -avd #{avd_name} > log/#{avd_name}.log &")

        android_serial = Retry.new(5, 10).start do
          AECC::Logger.instance.log("#attempting to find android-serial on port #{port.number}")
          android_serials = @terminal.adb("devices").scan(ANDROID_SERIAL_IDENTIFIER_REGEX)

          if(android_serials.empty?)
            AECC::Logger.instance.puts("raising: No device not found")
            raise 'No device not found'
          else
            android_serial = android_serials.detect do |android_serial|
              !android_serial.match(/#{port.number}/).nil?
            end

            if android_serial.nil?
              AECC::Logger.instance.log("raising: Device with port '#{port.number}' not found")
              raise "Device with port '#{port.number}' not found"
            else
              android_serial
            end
          end
        end
      end

      AECC::Logger.instance.log("#waiting for device to come online")
      @terminal.adb("-s #{android_serial} wait-for-device")

      #Add timeout in case device does not boot
      device_booted = false
      until (device_booted)
        AECC::Logger.instance.log("#waiting for device to boot")
        device_booted = terminal.adb("-s #{android_serial} shell getprop sys.boot_completed").include?(DEVICE_BOOTED_IDENTIFIER)
        AECC::Utils.wait(1)
      end

      AECC::Logger.instance.log("#Hurray! Device booted successfully")

      device = AECC::Device.new(android_serial, port)

      AECC::Utils.wait(5)

      device.assign_uuid(SecureRandom.uuid)

      AECC::Logger.instance.log("#Pressing home on device")
      device.press_home
      device
    end
  end
end
