require_relative 'port'
#http://stackoverflow.com/questions/2214377/how-to-get-serial-number-or-id-of-android-emulator-after-it-runs
#http://stackoverflow.com/questions/38910107/simultaneous-running-haxm-avd-emulator-limit
module AECC
  class Device
    USER_ROOT = 'root'
    USER_SHELL = 'shell'
    UUID_PROP_KEY = 'emu.uuid'
    ANDROID_TMP_DIR = '/data/local/tmp/'
    DEVICE_BOOTED_IDENTIFIER = '1'

    attr_reader :android_serial, :port_number, :uuid
    attr_writer :uuid

    @allowed_ports = (5554..5584).step(2).to_a.map { |number| Port.new(number).freeze }.freeze
    def self.allowed_ports
      @allowed_ports
    end

    def self.find(uuid)
      row = AECC::DB.instance.running_emulators.find(uuid)

      device = new(row['android_serial'], row['port'])

      if device.getprop(UUID_PROP_KEY) == uuid
        device.uuid = uuid
        device
      else
        raise 'Device not found'
      end
    end

    def initialize(android_serial, port_number)
      @android_serial = android_serial
      @port_number = port_number
    end

    def assign_uuid(uuid)
      setprop(UUID_PROP_KEY, uuid)
      assigned_uuid = ""

      Retry.new(5, 1).start do
        assigned_uuid = getprop(UUID_PROP_KEY)

        if (assigned_uuid.empty? || assigned_uuid != uuid)
          raise "uuid not set"
        end
      end

      @uuid = assigned_uuid
    end

    def push(apk, destination=ANDROID_TMP_DIR)
      remote_path = File.join(destination, apk.package)
      adb("push \"#{apk.path}\" \"#{remote_path}\"")

      remote_path
    end

    def install(remote_path)
      root("pm install \"#{remote_path}\"")
    end

    def uninstall(package)
      root("am uninstall #{package}")
    end

    def force_stop(package)
      root("am force-stop #{package}")
    end

    def print_alarms
      root("dumpsys alarm")
    end

    def press_home
      input_keyevent('KEYCODE_HOME')
    end

    def press_recent_apps
      input_keyevent('KEYCODE_APP_SWITCH')
    end

    def press_back
      input_keyevent('KEYCODE_BACK')
    end

    def press_power
      input_keyevent('KEYCODE_POWER')
    end

    def input_keyevent(keycode)
      shell("input keyevent #{keycode}")
    end

    def adbd_booted_as_root?
      shell("whoami").strip == USER_ROOT
    end

    def setprop(name, value)
      root("setprop #{name} #{value}")
    end

    def getprop(name)
      shell("getprop #{name}").strip
    end

    def booted?
      getprop("sys.boot_completed").include?(DEVICE_BOOTED_IDENTIFIER)
    end

    def permissions(package)
      raw_text = root("dumpsys package #{package}")
      raw_permissions = AECC::Utils.read_section(raw_text, /runtime permissions:/, /android.permission.*$/, /^ *$/)
      raw_permissions.map do |raw_permission|
        name = raw_permission.match(/android\.permission\.\w+/).to_s
        granted = (raw_permission.match(/granted=\w+/).to_s.split('=').last == 'true')
        AECC::Permission.new(name, granted)
      end
    end

    def revoke_permission(package, permission)
      root("pm revoke #{package} #{permission.name}")
    end

    def reset_permissions(package)
      granted_permissions = permissions(package).select(&:granted?)

      granted_permissions.each do |permission|
        revoke_permission(package, permission)
      end
    end


    private
    def shell(command)
      adb_shell(command, USER_SHELL)
    end

    def root(command)
      adb_shell(command, USER_ROOT)
    end

    def adb_shell(command, user)
      adb("shell su #{user} #{command}")
    end

    def adb(command)
      System.instance.terminal.adb("-s #{android_serial} #{command}")
    end
  end
end

