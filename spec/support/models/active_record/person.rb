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

RSpec.configure do |config|
  config.before do
    ActiveRecord::Base
      .connection
      .create_table(:people, force: true) do |t|
        t.string :name, null: false
        t.integer :age, null: false
      end
  end
end
