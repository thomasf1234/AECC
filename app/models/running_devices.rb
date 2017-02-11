require_relative '../../lib/in_memory/base_model'

class RunningDevices < InMemory::BaseModel
  column :android_serial
  column :port

  def initialize(android_serial, port)
    @android_serial = android_serial
    @port = port
  end
end