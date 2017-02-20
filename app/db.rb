require 'singleton'

module AECC
  class DB
    include Singleton

    attr_reader :running_emulators

    def initialize
      @running_emulators = Tables::RunningEmulators.new('running_emulators')
      freeze
    end

    def self.init
      instance
    end
  end
end
