# frozen_string_literal: true

module SuperDiff
  module Test
    module Models
      module ActiveRecord
        class Person < ::ActiveRecord::Base
          self.primary_key = 'person_id'

          def self.define_table
            ::ActiveRecord::Base
              .connection
              .create_table(
                :people,
                id: false,
                primary_key: 'person_id',
                force: true
              ) do |t|
              t.primary_key :person_id, null: false
              t.string :name, null: false
              t.integer :age, null: false
            end
          end
        end
      end
    end
  end
end
