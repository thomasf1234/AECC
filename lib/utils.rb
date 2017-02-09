class Utils
  def self.between_quotes(string)
    string.match(/'.*'/).to_s.gsub("'", "")
  end

  def self.latest_version(versions)
    ascending_versions = versions.sort_by {|version| Gem::Version.new(version)}
    return ascending_versions.last
  end

  def self.retry_block(count, rest_interval)
    retry_count = 0

    while retry_count < count do
      begin
        result = yield
        break
      rescue => e
        retry_count += 1
        result = e
        wait(rest_interval)
      end
    end

    if result.kind_of?(Exception)
      raise result
    else
      result
    end
  end

  def self.wait(seconds)
    sleep(seconds)
  end
end