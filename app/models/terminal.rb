require_relative '../logger'
require 'terminal'
require_relative '../../lib/utils'

module AECC
  class Terminal < Terminal::Base
    ANDROID_SDK_HOME_KEY = 'ANDROID_SDK_HOME'

    def initialize
      super
      @latest_build_tools_version = find_latest_build_tools_version
    end

    #@Override
    def before_exec(command)
      AECC::Logger.instance.log("executing: '#{command}'")
    end

    def adb(command)
      exec("#{File.join(ENV[ANDROID_SDK_HOME_KEY], 'platform-tools/adb')} #{command}")
    end

    def emulator(command)
      exec("#{File.join(ENV[ANDROID_SDK_HOME_KEY], 'tools/emulator')} #{command}")
    end

    def aapt(command)
      exec("#{File.join(ENV[ANDROID_SDK_HOME_KEY], "build-tools/#{@latest_build_tools_version}/aapt")} #{command}")
    end

    private
    def find_latest_build_tools_version
      versions = exec("ls #{File.join(ENV[ANDROID_SDK_HOME_KEY], 'build-tools')}").split("\n")
      AECC::Utils.latest_version(versions)
    end
  end
end
