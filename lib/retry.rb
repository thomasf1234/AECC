class Retry
  def initialize(count, rest_interval=nil)
    validate_count(count)
    validate_rest_interval(rest_interval)
    @count = count
    @rest_interval = rest_interval
  end

  def start
    retries = 0

    begin
      yield
    rescue StandardError => e
      if (retries >= @count)
        raise e
      else
        retries += 1
        sleep(@rest_interval) unless @rest_interval.nil?
        retry
      end
    end
  end

  private
  def validate_count(count)
    validate_positive_integer('count', count)
  end

  def validate_rest_interval(rest_interval)
    if !rest_interval.nil?
      validate_positive_integer('rest_interval', rest_interval)
    end
  end

  def validate_positive_integer(name, value)
    if (!positive_integer?(value))
      raise ArgumentError.new("#{name} must be a positive integer")
    end
  end

  def positive_integer?(obj)
    obj.kind_of?(Fixnum) && obj > 0 && obj.integer?
  end
end