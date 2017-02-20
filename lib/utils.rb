module AECC
  class Utils
    def self.between_quotes(string)
      string.match(/'.*'/).to_s.gsub("'", "")
    end

    def self.latest_version(versions)
      ascending_versions = versions.sort_by {|version| Gem::Version.new(version)}
      return ascending_versions.last
    end

    def self.wait(seconds)
      sleep(seconds)
    end

    def self.margin(s1, s2)
      s1 + ' '*(60-s1.length) + s2
    end

    def self.time_it
      t0 = Time.now
      result = yield
      t1 = Time.now
      duration = t1 - t0
      [result, duration]
    end
  end
end
