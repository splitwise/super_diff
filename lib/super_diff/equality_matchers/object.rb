module SuperDiff
  module EqualityMatchers
    class Object < Base
      def self.applies_to?(value)
        value.class == ::Object
      end

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
