class Utils
  def self.between_quotes(string)
    string.match(/'.*'/).to_s.gsub("'", "")
  end

  def self.latest_version(versions)
    ascending_versions = versions.sort_by {|version| Gem::Version.new(version)}
    return ascending_versions.last
  end

  def self.retry_block(count, rest_interval)
    if (!positive_integer(count))
      raise ArgumentError.new("count must be a positive integer")
    end

    if (!positive_integer(rest_interval))
      raise ArgumentError.new("rest_interval must be a positive integer")
    end

    retries = 0

    begin
      yield
    rescue StandardError => e
      if (retries >= count)
        raise e
      else
        retries += 1
        sleep(rest_interval)
        retry
      end
    end

    # while retries < count do
    #   begin
    #     result = yield
    #     break
    #   rescue StandardError => e
    #     retries += 1
    #     result = e
    #     wait(rest_interval)
    #   end
    # end
    #
    # if result.kind_of?(Exception)
    #   raise result
    # else
    #   result
    # end
  end

  def self.wait(seconds)
    sleep(seconds)
  end
end