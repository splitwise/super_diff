# frozen_string_literal: true

module SuperDiff
  module Basic
    module OperationTreeBuilders
      class DateLike < CustomObject
        def self.applies_to?(expected, actual)
          SuperDiff.date_like?(expected) && SuperDiff.date_like?(actual)
        end

        protected

        def attribute_names
          %w[year month day]
        end
      end
    end
  end
end
