require_relative '../logger'
require_relative '../../lib/utils'

module AECC
  class Terminal
    ANDROID_SDK_HOME_KEY = 'ANDROID_SDK_HOME'
    EXIT_STATUS_SUCCESS = 0
    DEFAULT_TIMEOUT_SECONDS = 30*60

    def initialize
      @history = []
      @latest_build_tools_version = find_latest_build_tools_version
    end

    def history
      @history
    end

    def last_command
      @history.last
    end

    def execute(command, timeout=DEFAULT_TIMEOUT_SECONDS)
      AECC::Logger.instance.log("executing: '#{command}'")
      formatted_command = timeout_cmd(command, timeout)
      @history.push(command)
      return_value = sh(formatted_command)
      exit_status = $?
      raise exit_status.inspect unless exit_status.exitstatus == EXIT_STATUS_SUCCESS
      return_value
    end

    def adb(command)
      execute("#{File.join(ENV[ANDROID_SDK_HOME_KEY], 'platform-tools/adb')} #{command}")
    end

    def emulator(command)
      execute("#{File.join(ENV[ANDROID_SDK_HOME_KEY], 'tools/emulator')} #{command}")
    end

    def aapt(command)

      execute("#{File.join(ENV[ANDROID_SDK_HOME_KEY], "build-tools/#{@latest_build_tools_version}/aapt")} #{command}")
    end

    private
    def timeout_cmd(command, duration)
      command
      # "timeout #{duration}s #{command}"
    end

    def sh(command)
      `#{command}`
    end

    def find_latest_build_tools_version
      versions = execute("ls #{File.join(ENV[ANDROID_SDK_HOME_KEY], 'build-tools')}").split("\n")
      AECC::Utils.latest_version(versions)
    end
  end
end
