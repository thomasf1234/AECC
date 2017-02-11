require_relative '../models/system'
require_relative '../../lib/utils'
require_relative '../../app/models/apk'

module AECC
  class ApkFactory
    def self.build(apk_source_path)
      dump = System.instance.terminal.aapt("dump badging #{apk_source_path}")
      package = Utils.between_quotes(dump.match(/package: *name='[^']*'/).to_s)
      launchable_activity = Utils.between_quotes(dump.match(/launchable-activity: *name='[^']*'/).to_s)

      Apk.new(apk_source_path, package, launchable_activity)
    end
  end
end