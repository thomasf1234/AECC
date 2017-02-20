ENV['ENV'] ||= 'test'
Bundler.require(:default, ENV['ENV'])
require_relative '../application'

RSpec.configure do |config|
  config.color= true
  config.order= 'rand'
  config.raise_errors_for_deprecations!

  config.before(:each) do
    AECC::DB.init
    AECC::DB.instance.running_emulators.delete_all
    AECC::DB.instance.running_emulators.vacuum
  end
end