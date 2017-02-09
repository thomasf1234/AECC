require 'fileutils'
require_relative 'lib/utils'
require_relative 'lib/log_file'
require_relative 'app/models/system'
require_relative 'app/models/device'
require_relative 'app/terminal'
require_relative 'app/models/apk'

def ensure_log_directory
  FileUtils.mkdir_p('log')
end

ensure_log_directory