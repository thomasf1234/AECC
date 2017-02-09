require 'singleton'
require_relative '../lib/log_file'

class ALogger
  include Singleton

  def initialize
    @log = LogFile.new('aecc')
  end

  def log(msg)
    @log.puts(msg)
  end
end