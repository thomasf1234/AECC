require 'spec_helper'

describe AECC::Apk do
  describe "#initialize" do
    it 'assigns the attributes' do
      apk = AECC::Apk.new("spec/samples/apk/test.apk", "com.example.ad.testapp2", "com.example.ad.testapp2.MainActivity")
      expect(apk.path).to eq("spec/samples/apk/test.apk")
      expect(apk.full_path).to eq(File.expand_path("spec/samples/apk/test.apk"))
      expect(apk.package).to eq("com.example.ad.testapp2")
      expect(apk.launchable_activity).to eq("com.example.ad.testapp2.MainActivity")
    end
  end
end
