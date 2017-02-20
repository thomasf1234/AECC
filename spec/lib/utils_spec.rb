require 'spec_helper'

describe AECC::Utils do
  describe ".between_quotes" do
    {
        "'a'" => "a",
        "'multipleletters'" => "multipleletters",
        "'spaces inbetween'" => "spaces inbetween",
        " 'whitespace'  " => "whitespace"
    }.each do |string, expected_result|
      it "catches evrything between the quotes and returns #{expected_result}" do
        expect(AECC::Utils.between_quotes(string)).to eq(expected_result)
      end
    end
  end

  describe ".latest_version" do
    let(:versions) { ['25.0.0', '24.0.1', '25.12.5', '23.1'] }

    it "returns the latest version" do
      expect(AECC::Utils.latest_version(versions)).to eq('25.12.5')
    end
  end

  describe ".read_section" do
    context 'nothing matching' do
      let(:text) do
        <<EOF
    requested permissions:
      android.permission.WRITE_EXTERNAL_STORAGE
      android.permission.RECORD_AUDIO
      android.permission.VIBRATE
      android.permission.RECEIVE_BOOT_COMPLETED
      android.permission.READ_EXTERNAL_STORAGE
    install permissions:
      android.permission.RECEIVE_BOOT_COMPLETED: granted=true
      android.permission.VIBRATE: granted=true
    User 0: ceDataInode=21245 installed=true hidden=false suspended=false stopped=false notLaunched=false enabled=0
      runtime permissions:


Dexopt state:
EOF
      end

      it 'returns no matches' do
        expect(AECC::Utils.read_section(text, /runtime permissions:/, /android.permission.*$/, /^ *$/)).to eq([])
      end
    end

    context 'some matching' do
      let(:text) do
        <<EOF
    requested permissions:
      android.permission.WRITE_EXTERNAL_STORAGE
      android.permission.RECORD_AUDIO
      android.permission.VIBRATE
      android.permission.RECEIVE_BOOT_COMPLETED
      android.permission.READ_EXTERNAL_STORAGE
    install permissions:
      android.permission.RECEIVE_BOOT_COMPLETED: granted=true
      android.permission.VIBRATE: granted=true
    User 0: ceDataInode=21245 installed=true hidden=false suspended=false stopped=false notLaunched=false enabled=0
      runtime permissions:
        android.permission.RECORD_AUDIO: granted=true
        something_unknown
        android.permission.READ_EXTERNAL_STORAGE: granted=true
        android.permission.WRITE_EXTERNAL_STORAGE: granted=false


Dexopt state:
EOF
      end

      it 'returns all matching' do
        expect(AECC::Utils.read_section(text, /runtime permissions:/, /android\.permission.*$/, /^ *$/)).to eq([
                                                                                                             'android.permission.RECORD_AUDIO: granted=true',
                                                                                                             'android.permission.READ_EXTERNAL_STORAGE: granted=true',
                                                                                                             'android.permission.WRITE_EXTERNAL_STORAGE: granted=false'
                                                                                                         ])
      end
    end
  end
end
