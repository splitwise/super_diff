module SuperDiff
  module OperationalSequencers
    class TimeLike < CustomObject
      def self.applies_to?(expected, actual)
        (expected.is_a?(Time) && actual.is_a?(Time)) ||
          (
            # Check for ActiveSupport's #acts_like_time? for their time-like objects
            # (like ActiveSupport::TimeWithZone).
            expected.respond_to?(:acts_like_time?) && expected.acts_like_time? &&
            actual.respond_to?(:acts_like_time?) && actual.acts_like_time?
          )
      end

      protected

      def attribute_names
        base = ["year", "month", "day", "hour", "min", "sec", "nsec", "zone", "gmt_offset"]

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
