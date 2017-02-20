module AECC
  class Stopwatch
    def start
      @start_time = Time.now
    end

    def get_elapsed_time
      if @start_time.nil?
        0
      else
        Time.now - @start_time
      end
    end
  end
end