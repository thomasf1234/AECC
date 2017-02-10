require 'spec_helper'

describe Utils do
  describe ".between_quotes" do
    {
        "'a'" => "a",
        "'multipleletters'" => "multipleletters",
        "'spaces inbetween'" => "spaces inbetween",
        " 'whitespace'  " => "whitespace"
    }.each do |string, expected_result|
      it "catches evrything between the quotes and returns #{expected_result}" do
        expect(Utils.between_quotes(string)).to eq(expected_result)
      end
    end
  end

  describe ".latest_version" do
    let(:versions) { ['25.0.0', '24.0.1', '25.12.5', '23.1'] }

    it "returns the latest version" do
      expect(Utils.latest_version(versions)).to eq('25.12.5')
    end
  end
end
