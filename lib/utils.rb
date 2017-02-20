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
      s1 + ' '*(100-s1.length) + s2
    end

    def self.time_it
      t0 = Time.now
      result = yield
      t1 = Time.now
      duration = t1 - t0
      [result, duration]
    end

    def self.read_section(text, start_line_regex, match_regex, terminator_regex)
      found_start = false
      matches = []
      text.split("\n").each do |line|
        if found_start
          if line.match(terminator_regex)
            break
          elsif line.match(match_regex)
            matches << line.strip
          end
        elsif line.match(start_line_regex)
          found_start = true
        end
      end

      matches
    end
  end
end
