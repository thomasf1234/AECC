require 'spec_helper'

describe AECC::Retry do
  describe "#initialize" do
    context 'only count passed' do
      context 'not a positive integer' do
        it 'raises argument error' do
          [nil, 'string', -1, 0, 1.1].each do |invalid_count|
            expect { AECC::Retry.new(invalid_count) }.to raise_error(ArgumentError, "count must be a positive integer")
          end
        end
      end

      context 'positive integer' do
        it 'return Retry object' do
          [1, 10, 4].each do |valid_count|
            retrier  = AECC::Retry.new(valid_count)
            expect(retrier.instance_variable_get(:@count)).to eq(valid_count)
          end
        end
      end
    end

    context 'count and rest_interval passed' do
      context 'not positive integers' do
        it 'return Retry object' do
          [nil, 'string', -1, 0, 1.1].each do |invalid_count|
            expect { AECC::Retry.new(invalid_count, 4) }.to raise_error(ArgumentError, "count must be a positive integer")
          end

          ['string', -1, 0, 1.1].each do |invalid_rest_interval|
            expect { AECC::Retry.new(1, invalid_rest_interval) }.to raise_error(ArgumentError, "rest_interval must be a positive integer")
          end

          [nil, 'string', -1, 0, 1.1].each do |invalid|
            expect { AECC::Retry.new(invalid, invalid) }.to raise_error(ArgumentError, "count must be a positive integer")
          end
        end
      end

      context 'positive integers' do
        it 'return Retry object' do
          retrier  = AECC::Retry.new(3, 10)
          expect(retrier.instance_variable_get(:@count)).to eq(3)
          expect(retrier.instance_variable_get(:@rest_interval)).to eq(10)
        end
      end

      context 'nil for rest_interval' do
        it 'return Retry object' do
          retrier  = AECC::Retry.new(3, nil)
          expect(retrier.instance_variable_get(:@count)).to eq(3)
          expect(retrier.instance_variable_get(:@rest_interval)).to eq(nil)
        end
      end
    end
  end

  describe "#start (2 retries)" do
    let(:retrier) { AECC::Retry.new(2) }

    context 'success first try' do
      it 'returns the result of the block' do
        result = retrier.start { 'a' }
        expect(result).to eq('a')
      end
    end

    context "fail first try" do
      context "success first retry" do
        it 'retries once and returns result of the block' do
          i = 0

          result = retrier.start do
            if i < 1
              i += 1
              raise "Error!"
            else
              'a'
            end
          end

          expect(result).to eq('a')
          expect(i).to eq(1)
        end
      end

      context "fail first retry" do
        context "success second retry" do
          it 'returns result of the block' do
            i = 0

            result = retrier.start do
              if i < 2
                i += 1
                raise "Error!"
              else
                'a'
              end
            end

            expect(result).to eq('a')
            expect(i).to eq(2)
          end
        end

        context "fail second retry" do
          it 'returns result of the block' do
            i = 0

            expect do
              retrier.start do
                if i < 3
                  i += 1
                  raise "Error!"
                else
                  'a'
                end
              end
            end.to raise_error(RuntimeError, "Error!")

            expect(i).to eq(3)
          end
        end
      end
    end
  end
end
