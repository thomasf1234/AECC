require 'spec_helper'

describe AECC::Permission do
  describe "#initialize" do
    context 'granted' do
      it 'assigns the attributes' do
        permission = AECC::Permission.new("android.permission.RECORD_AUDIO", true)
        expect(permission.name).to eq("android.permission.RECORD_AUDIO")
        expect(permission.granted?).to eq(true)
      end
    end

    context 'not granted' do
      it 'assigns the attributes' do
        permission = AECC::Permission.new("android.permission.WRITE_STORAGE", false)
        expect(permission.name).to eq("android.permission.WRITE_STORAGE")
        expect(permission.granted?).to eq(false)
      end
    end
  end
end
