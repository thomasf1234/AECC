module AECC
  class Apk
    attr_reader :path, :package, :launchable_activity

    def initialize(path, package, launchable_activity)
      @path = path
      @package = package
      @launchable_activity = launchable_activity
    end

    def full_path
      File.expand_path(@path)
    end
  end
end