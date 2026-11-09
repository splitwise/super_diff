# frozen_string_literal: true

module SuperDiff
  module Test
    module Models
      module ActiveRecord
        class Order < ::ActiveRecord::Base
          def self.define_table
            ::ActiveRecord::Base
              .connection
              .create_table(
                :orders,
                force: true,
                primary_key: %i[store_id sku]
              ) do |t|
              t.integer :latest_outcome, null: false
              t.string :details
              t.integer :store_id, null: false
              t.string :sku, null: false
            end
          end
        end
      end
    end
  end
end
