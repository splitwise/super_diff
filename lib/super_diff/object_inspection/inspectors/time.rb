module SuperDiff
  module ObjectInspection
    module Inspectors
      TIME_FORMAT = "%Y-%m-%d %H:%M:%S.%3N %Z %:z".freeze

      Time = InspectionTree.new do
        add_text do |time|
          "#{time.strftime(TIME_FORMAT)} (#{time.class})"
        end
      end
    end
  end
end
