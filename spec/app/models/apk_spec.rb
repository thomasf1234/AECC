require 'spec_helper'

describe Apk do
  describe "#initialize" do
    let(:apk) { Apk.new(sample_apk_path) }
    let(:sample_apk_path) { "spec/samples/apk/test.apk" }

    it 'assigns the attributes' do
      expect(apk.path).to eq(sample_apk_path)
      expect(apk.full_path).to eq(File.expand_path(sample_apk_path))
      expect(apk.package).to eq("com.example.ad.testapp2")
      expect(apk.launchable_activity).to eq("com.example.ad.testapp2.MainActivity")
    end
  end
end
