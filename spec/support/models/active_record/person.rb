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

ActiveRecord::Base.connection.create_table(:people) do |t|
  t.string :name, null: false
  t.integer :age, null: false
end

RSpec.configure do |config|
  config.before do
    ActiveRecord::Base.connection.execute(
      "DELETE FROM people",
    )
    ActiveRecord::Base.connection.execute(
      "DELETE FROM sqlite_sequence WHERE name='people'",
    )
  end
end
