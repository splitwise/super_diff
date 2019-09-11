module SuperDiff
  module Test
    module Models
      module ActiveRecord
        class ShippingAddress < ::ActiveRecord::Base
        end
      end
    end
  end
end

ActiveRecord::Base.connection.create_table(:shipping_addresses) do |t|
  t.string :line_1, null: false, default: ""
  t.string :line_2, null: false, default: ""
  t.string :city, null: false, default: ""
  t.string :state, null: false, default: ""
  t.string :zip, null: false, default: ""
end

RSpec.configure do |config|
  config.before do
    ActiveRecord::Base.connection.execute(
      "DELETE FROM shipping_addresses",
    )
    ActiveRecord::Base.connection.execute(
      "DELETE FROM sqlite_sequence WHERE name='shipping_addresses'",
    )
  end
end
