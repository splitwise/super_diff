# frozen_string_literal: true

module SuperDiff
  module Test
    module Models
      module ActiveRecord
        class TimeSeriesData < ::ActiveRecord::Base
          def self.define_table
            ::ActiveRecord::Base
              .connection
              .create_table(
                :time_series_data,
                force: true,
                id: false
              ) do |t|
              t.integer :value, null: false
              t.datetime :at, null: false
            end
          end
        end
      end
    end
  end
end
