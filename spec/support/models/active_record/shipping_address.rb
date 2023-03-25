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

RSpec.configure do |config|
  config.before do
    ActiveRecord::Base
      .connection
      .create_table(:shipping_addresses, force: true) do |t|
        t.string :line_1, null: false, default: ""
        t.string :line_2, null: false, default: ""
        t.string :city, null: false, default: ""
        t.string :state, null: false, default: ""
        t.string :zip, null: false, default: ""
      end
  end
end
