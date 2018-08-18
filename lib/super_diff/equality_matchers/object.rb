require_relative "base"

module SuperDiff
  module EqualityMatchers
    class Object < Base
      def fail
        <<~OUTPUT.strip
          Differing #{Helpers.plural_type_for(actual)}.

          #{Helpers.style :deleted,  "Expected: #{expected.inspect}"}
          #{Helpers.style :inserted, "  Actual: #{actual.inspect}"}
        OUTPUT
      end
    end
  end
end
