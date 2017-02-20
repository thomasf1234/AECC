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

    def initialize
      @terminal = AECC::Terminal.new
      ObjectSpace.define_finalizer(self,
                                   self.class.method(:finalize).to_proc)
    end

    def self.finalize(id)
      instance.kill_all_emulators
      puts "Killed all emulators"
    end

    def terminal
      @terminal
    end

    #Change to find Device.find_by(android_serial)
    def kill_all_emulators
      android_serials = terminal.adb("devices").scan(/emulator-\d+/)

      android_serials.each do |android_serial|
        terminal.adb("-s #{android_serial} emu kill")
      end

      #TODO : must check here that all ports are cleared
      AECC::DB.instance.running_emulators.delete_all
    end

    def kill(uuid)
      row = AECC::DB.instance.running_emulators.find(uuid)
      android_serial = row['android_serial']
      terminal.adb("-s #{android_serial} emu kill")
      AECC::DB.instance.running_emulators.delete(uuid)
    end

    def start_emulator(avd_name)
      AECC::Logger.instance.log("starting adb server")
      terminal.adb('start-server')

      uuid = nil
      AECC::Device.allowed_ports.each do |port|
        if port.free?
          begin
            uuid = AECC::DB.instance.running_emulators.insert({'android_serial' => nil, 'port' => port.number})
            break
          rescue IMDB::UniqueConstraintViolation => e
            # ignored
          end
        end
      end

      if uuid.nil?
        raise "No free ports available"
      else
        row = AECC::DB.instance.running_emulators.find(uuid)
        port_number = row['port']
        AECC::Logger.instance.log("#starting emulator avd #{avd_name}")
        #TODO : get PID
        terminal.emulator("-wipe-data -no-boot-anim -shell -netdelay none -netspeed full -port #{port_number} -avd #{avd_name} > log/#{avd_name}.log &")

        android_serial = Retry.new(5, 10).start do
          AECC::Logger.instance.log("#attempting to find android-serial on port #{port_number}")
          android_serials = @terminal.adb("devices").scan(ANDROID_SERIAL_IDENTIFIER_REGEX)

          if(android_serials.empty?)
            AECC::Logger.instance.puts("raising: No device not found")
            raise 'No device not found'
          else
            android_serial = android_serials.detect do |android_serial|
              !android_serial.match(/#{port_number}/).nil?
            end

            if android_serial.nil?
              AECC::Logger.instance.log("raising: Device with port '#{port_number}' not found")
              raise "Device with port '#{port_number}' not found"
            else
              android_serial
            end
          end
        end

        AECC::DB.instance.running_emulators.update(uuid, {'android_serial' => android_serial, 'port' => port_number})
      end

      AECC::Logger.instance.log("#waiting for device to come online")
      terminal.adb("-s #{android_serial} wait-for-device")

      device = AECC::Device.new(android_serial, port_number)

      Timeout::timeout(180) do
        until (device.booted?)
          AECC::Logger.instance.log("#waiting for device to boot")
          AECC::Utils.wait(1)
        end
      end


      AECC::Logger.instance.log("#Device booted successfully")

      AECC::Utils.wait(5)

      #device booted so assign the uuid
      device.assign_uuid(uuid)

      AECC::Logger.instance.log("#Pressing home on device")
      device.press_home
      device
    end
  end
end
