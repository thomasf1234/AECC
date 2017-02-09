require 'test/unit'
require_relative '../../../app/models/apk'

class ApkTest < Test::Unit::TestCase
  def test_apk
    apk = Apk.new("test/samples/apk/test.apk")

    assert_equal(File.expand_path("test/samples/apk/test.apk"), apk.full_path)
    assert_equal("test/samples/apk/test.apk", apk.path)
    assert_equal("com.example.ad.testapp2", apk.package)
    assert_equal("com.example.ad.testapp2.MainActivity", apk.launchable_activity)
  end
end