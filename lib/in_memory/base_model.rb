require 'set'

module InMemory
  class BaseModel
    def self.column(name)
      @columns ||= Set.new
      @columns << name
      attr_reader(name)
    end

    def self.columns
      @columns
    end

    def columns
      self.class.columns
    end
  end
end