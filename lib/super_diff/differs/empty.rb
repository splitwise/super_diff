module SuperDiff
  module Differs
    class Empty < Base
      def self.applies_to?(value)
        true
      end

      def call
        ""
      end
    end
  end
end
