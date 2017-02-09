require 'timeout'
require 'socket'

class Port
  LOCALHOST = '127.0.0.1'
  DEFAULT_TIMEOUT = 5

  attr_reader :number

  def initialize(number)
    @number = number
  end

  def free?
    free = false

    begin
      socket = nil

      Timeout::timeout(DEFAULT_TIMEOUT) do
        socket = Socket.new(:INET, :STREAM)
        sockaddr = Socket.sockaddr_in(@number, LOCALHOST)
        if socket.bind(sockaddr)
          free = true
        end
      end
    rescue Errno::EADDRINUSE, Errno::ETIMEDOUT, Timeout::Error
    ensure
      if !socket.nil?
        if !socket.closed?
          socket.close
        end
      end
    end

    return free
  end
end