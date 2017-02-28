require 'spec_helper'

describe AECC::Terminal do
  let(:terminal) { AECC::Terminal.new }

  describe "#adb" do
    before :each do
      allow(terminal).to receive(:sh).and_return(true)
      terminal.adb("push tmp/test.apk /tmp/com.example.test")
    end

    it "executes the correct formed command" do
      expect(terminal.history.last.command).to eq("#{ENV['ANDROID_SDK_HOME']}/platform-tools/adb push tmp/test.apk /tmp/com.example.test")
    end
  end

  describe "#emulator" do
    before :each do
      allow(terminal).to receive(:sh).and_return(true)
      terminal.emulator("-wipe-data -no-boot-anim -shell -netdelay none -netspeed full -avd Pixel_C_API_23")
    end

    it "executes the correct formed command" do
      expect(terminal.history.last.command).to eq("#{ENV['ANDROID_SDK_HOME']}/tools/emulator -wipe-data -no-boot-anim -shell -netdelay none -netspeed full -avd Pixel_C_API_23")
    end
  end

  describe "#aapt" do
    before :each do
      allow_any_instance_of(AECC::Terminal).to receive(:find_latest_build_tools_version).and_return('25.0.1')
      allow(terminal).to receive(:sh).and_return(true)
      terminal.aapt("dump badge test/samples/apk/test.apk")
    end

    it "executes the correct formed command" do
      expect(terminal.history.last.command).to eq("#{ENV['ANDROID_SDK_HOME']}/build-tools/25.0.1/aapt dump badge test/samples/apk/test.apk")
    end
  end
end
