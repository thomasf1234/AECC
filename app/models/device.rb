require_relative 'port'
#http://stackoverflow.com/questions/2214377/how-to-get-serial-number-or-id-of-android-emulator-after-it-runs
#http://stackoverflow.com/questions/38910107/simultaneous-running-haxm-avd-emulator-limit
class Device
  USER_ROOT = 'root'
  USER_SHELL = 'shell'
  UUID_PROP_KEY = 'emu.uuid'
  ANDROID_TMP_DIR = '/data/local/tmp/'
  attr_reader :avd_name, :serial_number, :port, :uuid

  @allowed_ports = (5554..5584).step(2).to_a.map { |number| Port.new(number) }
  def self.allowed_ports
    @allowed_ports
  end

  def initialize(avd_name, serial_number, port)
    @avd_name = avd_name
    @serial_number = serial_number
    @port = port
  end

  def assign_uuid(uuid)
    setprop(UUID_PROP_KEY, uuid)
    assigned_uuid = ""

    Utils.retry_block(5, 1) do
      assigned_uuid = getprop(UUID_PROP_KEY)

      if (assigned_uuid.empty? || assigned_uuid != uuid)
        raise "uuid not set"
      end
    end

    @uuid = assigned_uuid
  end

  def push(apk, destination=ANDROID_TMP_DIR)
    remote_path = File.join(destination, apk.package)
    shell("push #{apk.path} #{remote_path}")

    return remote_path
  end

  def install(remote_path)
    root("pm install #{remote_path}")
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
    shell("input keyevent KEYCODE_HOME")
  end

  def press_recent_apps
    shell("input keyevent KEYCODE_APP_SWITCH")
  end

  def press_back
    shell("input keyevent KEYCODE_BACK")
  end

  def press_power
    shell("input keyevent KEYCODE_POWER")
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

  private
  def shell(command)
    adb_shell(command, USER_SHELL)
  end

  def root(command)
    adb_shell(command, USER_ROOT)
  end

  def adb_shell(command, user)
    System.instance.terminal.adb("-s #{serial_number} shell su #{user} #{command}")
  end
end

