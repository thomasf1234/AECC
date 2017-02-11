require 'spec_helper'

describe AECC::Port do
  describe "#free?" do
    context 'already bound to' do
      it 'cannot bind to the port so returns false' do
        server = nil

        begin
          server = TCPServer.new('127.0.0.1', 0)
          bound_port = server.addr[1]
          port = AECC::Port.new(bound_port)
          expect(port.free?).to eq(false)
        ensure
          if !server.nil?
            if !server.closed?
              server.close
            end
          end
        end
      end
    end

    context 'not already bound to' do
      it 'can bind to the port so returns true' do
        server = nil

        begin
          server = TCPServer.new('127.0.0.1', 0)
          bound_port = server.addr[1]
          server.close
          port = AECC::Port.new(bound_port)
          expect(port.free?).to eq(true)
        ensure
          if !server.nil?
            if !server.closed?
              server.close
            end
          end
        end
      end
    end
  end
end
