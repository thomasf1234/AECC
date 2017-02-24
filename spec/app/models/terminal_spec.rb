require 'spec_helper'

describe AECC::Terminal do
  let(:terminal) { AECC::Terminal.new }

  describe "#execute" do
    context "success" do
      it 'returns the result of the command' do
        result = terminal.execute("echo Hi")
        expect(result).to eq("Hi\n")
      end
    end

    context "unknown command" do
      it 'raises an Errno::ENOENT exception because it cannot find the command' do
        expect { terminal.execute("unknown command") }.to raise_exception
      end
    end

    context "non_successful_return_status" do
      it 'raises an RuntimeError exception because the exit status != 0' do
        expect { terminal.execute("false") }.to raise_exception(RuntimeError, /exit 1/)
      end
    end

    #   #TODO : Need to run on Linux
    #   # def test_execute_timeout
    #   #   terminal = Terminal.new('/usr/lib/android-sdk')
    #   #
    #   #   begin
    #   #     terminal.execute("sleep 10")
    #   #     fail("command should have thrown timeout exception")
    #   #   rescue => e
    #   #     assert_equal(Timeout::Error, e.class)
    #   #     assert_equal('exit 124', e.message.match(/exit \d+/).to_s)
    #   #   end
    #   # end
  end

  describe "#history" do
    context "successful command" do
      it 'lists the commands run in order' do
        terminal.execute("echo Hi")
        terminal.execute("ls -l")
        expect(terminal.history.last(2)).to eq(["echo Hi", "ls -l"])
      end
    end
  end

  describe "#adb" do
    before :each do
      allow(terminal).to receive(:sh).and_return(true)
      terminal.adb("push tmp/test.apk /tmp/com.example.test")
    end

    it "executes the correct formed command" do
      expect(terminal.history.last).to eq("#{ENV['ANDROID_SDK_HOME']}/platform-tools/adb push tmp/test.apk /tmp/com.example.test")
    end
  end

  describe "#emulator" do
    before :each do
      allow(terminal).to receive(:sh).and_return(true)
      terminal.emulator("-wipe-data -no-boot-anim -shell -netdelay none -netspeed full -avd Pixel_C_API_23")
    end

    it "executes the correct formed command" do
      expect(terminal.history.last).to eq("#{ENV['ANDROID_SDK_HOME']}/tools/emulator -wipe-data -no-boot-anim -shell -netdelay none -netspeed full -avd Pixel_C_API_23")
    end
  end

  describe "#aapt" do
    before :each do
      allow_any_instance_of(AECC::Terminal).to receive(:find_latest_build_tools_version).and_return('25.0.1')
      allow(terminal).to receive(:sh).and_return(true)
      terminal.aapt("dump badge test/samples/apk/test.apk")
    end

    it "executes the correct formed command" do
      expect(terminal.history.last).to eq("#{ENV['ANDROID_SDK_HOME']}/build-tools/25.0.1/aapt dump badge test/samples/apk/test.apk")
    end
  end
end
