require 'singleton'
require_relative '../lib/log_file'

#change to use ruby Logger
#Maybe logging module that allows each class to log (better approach)
module AECC
  class Logger
    include Singleton

    def initialize
      @log = LogFile.new('aecc')
      ObjectSpace.define_finalizer(self,
                                   self.class.method(:finalize).to_proc)
    end

    def Logger.finalize(id)
      instance.close_log
      puts "AECC::Logger closing log"
    end

    def log(msg)
      @log.puts(msg)
    end

    def close_log
      @log.close
    end
  end
end
