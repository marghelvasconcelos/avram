require "./base"

module Avram::Migrator::Columns
  class UUIDColumn(T) < Base
    @default : T | Nil = nil

    def initialize(@name, @nilable, @default)
    end

    def column_type
      "uuid"
    end
  end
end
