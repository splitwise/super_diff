module SuperDiff
  module OperationTreeBuilders
    class TimeLike < CustomObject
      def self.applies_to?(expected, actual)
        SuperDiff.time_like?(expected) && SuperDiff.time_like?(actual)
      end

      protected

      def attribute_names
        base = %w[year month day hour min sec subsec zone utc_offset]

        # If timezones are different, also show a normalized timestamp at the
        # end of the diff to help visualize why they are different moments in
        # time.
        if actual.zone != expected.zone
          base + ["utc"]
        else
          base
        end
      end
    end
  end
end
