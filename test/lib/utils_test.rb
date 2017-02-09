require 'test/unit'
require_relative '../../lib/utils'

class UtilsTest < Test::Unit::TestCase
  def test_latest_version
    latest_version = Utils.latest_version(['25.0.0', '24.0.1', '25.12.5', '23.1'])
    assert_equal('25.12.5', latest_version)
  end
end