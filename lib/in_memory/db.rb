require 'securerandom'
require 'singleton'
require 'set'

module InMemory
  class DB
    include Singleton
    include Lock

    def initialize
      @db = Set.new
    end

    def where(params)

    end

    def insert(model)
      lock do
        @db[model.class.name] ||= []

        row = {uuid: SecureRandom.uuid}
        model.columns.each do |column|
          row[column] = model.send(column)
        end
        @db[model.class.name] << row
        row
      end
    end

    def update(model)

    end

    def delete(model_klass, uuid)

    end

    def unique_uuid

    end

    def db
      @db
    end
  end
end