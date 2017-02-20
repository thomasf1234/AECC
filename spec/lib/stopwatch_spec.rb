require 'spec_helper'

module StopwatchSpec
  class Helper
    def self.decimal_equal(actual, expected, delta)
      (actual < expected + delta) && (actual > expected - delta)
    end
  end

  describe AECC::Stopwatch do
    let(:stopwatch) { AECC::Stopwatch.new }

    describe "#get_elapsed_time" do
      context 'not-started' do
        it 'returns 0' do
          expect(stopwatch.get_elapsed_time).to eq(0)
        end
      end

      context 'started' do
        it 'returns elapsed time in seconds' do
          stopwatch.start
          sleep(1)
          expect(Helper.decimal_equal(stopwatch.get_elapsed_time, 1, 0.1)).to eq(true)
          sleep(2)
          expect(Helper.decimal_equal(stopwatch.get_elapsed_time, 3, 0.1)).to eq(true)
        end
      end
    end
  end
end

