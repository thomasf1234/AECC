require 'spec_helper'

module DeviceSpec
  describe AECC::Device do
    describe 'class methods' do
      describe ".allowed_ports" do
        it 'is in expected range, cannot be modified' do
          expect(AECC::Device.allowed_ports.map(&:number)).to eq([5554, 5556, 5558, 5560, 5562, 5564, 5566, 5568,
                                                                  5570, 5572, 5574, 5576, 5578, 5580, 5582, 5584])

          expect { AECC::Device.allowed_ports.first.instance_variable_set(:@number, 6) }.to raise_error("can't modify frozen AECC::Port")
        end
      end

      describe '.find' do
        let!(:device) { AECC::Device.new('emulator-5554', 5554) }

        before :each do
          allow(AECC::Device).to receive(:new).with('emulator-5554', 5554).and_return(device)
        end

        context 'no record found for uuid passed' do
          let(:uuid) { '3f819ea3-f283-45de-ac87-fe36b8da1c50' }

          it 'raises error' do
            expect { AECC::Device.find(uuid) }.to raise_error(IMDB::RowNotFound)
          end
        end

        context 'record found for uuid passed' do
          let(:uuid) do
            AECC::DB.instance.running_emulators.insert({'android_serial' => 'emulator-5554', 'port' => 5554})
          end

          context 'uuid not found on the device' do
            before :each do
              allow(device).to receive(:getprop).with(AECC::Device::UUID_PROP_KEY).and_return('3f819ea3-f283-45de-ac87-fe36b8da1c50')
            end

            it 'raises error' do
              expect { AECC::Device.find(uuid) }.to raise_error('Device not found')
            end
          end

          context 'uuid found on the device' do
            before :each do
              allow(device).to receive(:getprop).with(AECC::Device::UUID_PROP_KEY).and_return(uuid)
            end

            it 'returns a valid device instance' do
              found_device =   AECC::Device.find(uuid)

              expect(found_device.class).to eq(AECC::Device)
              expect(found_device.android_serial).to eq('emulator-5554')
              expect(found_device.port_number).to eq(5554)
              expect(found_device.uuid).to eq(uuid)
            end
          end
        end
      end
    end
  end
end

