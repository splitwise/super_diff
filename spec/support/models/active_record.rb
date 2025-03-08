# frozen_string_literal: true

module SuperDiff
  module Test
    module Models
      module ActiveRecord
        def self.define_tables
          SuperDiff::Test::Models::ActiveRecord::Person.define_table
          SuperDiff::Test::Models::ActiveRecord::ShippingAddress.define_table
          SuperDiff::Test::Models::ActiveRecord::TimeSeriesData.define_table
        end
      end
    end
  end
end
