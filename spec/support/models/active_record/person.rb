if defined?(ActiveRecord)
  module SuperDiff
    module Test
      module Models
        module ActiveRecord
          class Person < ::ActiveRecord::Base
          end
        end
      end
    end
  end

  ::ActiveRecord::Base.connection.create_table(:people) do |t|
    t.string :name, null: false
    t.integer :age, null: false
  end
end
