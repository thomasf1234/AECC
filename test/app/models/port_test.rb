require 'test/unit'
require_relative '../../../app/models/port'

class PortTest < Test::Unit::TestCase

  # test if we can bind to the given port
  def test_bound_port
    server = nil

    begin
      server = TCPServer.new('127.0.0.1', 0)
      bound_port = server.addr[1]
      port = Port.new(bound_port)
      assert_equal(false, port.free?)
    ensure
      if !server.nil?
        if !server.closed?
          server.close
        end
      end
    end
  end

  def test_free_port
    server = nil

    begin
      server = TCPServer.new('127.0.0.1', 0)
      bound_port = server.addr[1]
      server.close
      port = Port.new(bound_port)
      assert_equal(true, port.free?)
    ensure
      if !server.nil?
        if !server.closed?
          server.close
        end
      end
    end
  end
end