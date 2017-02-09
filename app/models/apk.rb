require_relative '../models/system'
require_relative '../../lib/utils'

class Apk
  attr_reader :path, :package, :launchable_activity

  def initialize(path)
    @path = path
    extract_attributes
  end

  def full_path
    File.expand_path(@path)
  end

  private
  def extract_attributes
    dump = System.instance.terminal.aapt("dump badging #{@path}")
    @package = Utils.between_quotes(dump.match(/package: *name='[^']*'/).to_s)
    @launchable_activity = Utils.between_quotes(dump.match(/launchable-activity: *name='[^']*'/).to_s)
  end
end