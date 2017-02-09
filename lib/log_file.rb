require 'date'

class LogFile
  def initialize(file_name)
    @file = File.new("log/#{file_name}.log", 'a+')
  end

  def puts(message)
    @file.puts "[#{DateTime.now}]" + message
    @file.flush
  end

  def close
    @file.close
  end
end