require 'test/unit'
require_relative '../../app/terminal'

class TerminalTest < Test::Unit::TestCase
  def test_execute
    terminal = Terminal.new

    result = terminal.execute("echo Hi")
    assert_equal("Hi\n", result)
  end

  def test_execute_unknown_command
    terminal = Terminal.new

    begin
      terminal.execute("unknown command")
      fail("command should have thrown exception")
    rescue => e
      assert_equal(e.class, Errno::ENOENT)
      assert_equal(e.message, "No such file or directory - unknown")
    end
  end

  def test_execute_non_successful_return_status
    terminal = Terminal.new

    begin
      terminal.execute("! true")
      fail("command should have thrown exception")
    rescue => e
      assert_equal(RuntimeError, e.class)
      assert_equal('exit 1', e.message.match(/exit \d+/).to_s)
    end
  end

  #TODO : Need to run on Linux
  # def test_execute_timeout
  #   terminal = Terminal.new('/usr/lib/android-sdk')
  #
  #   begin
  #     terminal.execute("sleep 10")
  #     fail("command should have thrown timeout exception")
  #   rescue => e
  #     assert_equal(Timeout::Error, e.class)
  #     assert_equal('exit 124', e.message.match(/exit \d+/).to_s)
  #   end
  # end

  def test_adb
    terminal = Terminal.new(true)

    assert_equal(nil, terminal.get_last_command)
    terminal.adb("push tmp/test.apk /tmp/com.example.test")
    assert_equal("#{ENV['ANDROID_SDK_HOME']}/platform-tools/adb push tmp/test.apk /tmp/com.example.test", terminal.get_last_command)
  end

  def test_emulator
    terminal = Terminal.new(true)

    assert_equal(nil, terminal.get_last_command)
    terminal.emulator("-wipe-data -no-boot-anim -shell -netdelay none -netspeed full -avd Pixel_C_API_23")
    assert_equal("#{ENV['ANDROID_SDK_HOME']}/tools/emulator -wipe-data -no-boot-anim -shell -netdelay none -netspeed full -avd Pixel_C_API_23", terminal.get_last_command)
  end

  def test_aapt
    terminal = Terminal.new(true)

    assert_equal(nil, terminal.get_last_command)
    terminal.aapt("dump badge test/samples/apk/test.apk")
    assert_equal("#{ENV['ANDROID_SDK_HOME']}/build-tools/25.0.1/aapt dump badge test/samples/apk/test.apk", terminal.get_last_command)
  end
end