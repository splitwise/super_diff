require_relative "base"

module SuperDiff
  module Differs
    class Object < Base
      def fail
        <<~OUTPUT.strip
          Differing #{plural_type_for(actual)}.

          #{style :deleted,  "Expected: #{expected.inspect}"}
          #{style :inserted, "  Actual: #{actual.inspect}"}
        OUTPUT
      end
    end
  end
end
