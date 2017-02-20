module AECC
  class Permission
    attr_reader :name

    def initialize(name, granted)
      @name = name
      @granted = granted
    end

    def granted?
      @granted == true
    end
  end
end