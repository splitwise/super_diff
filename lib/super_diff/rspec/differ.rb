module SuperDiff
  module RSpec
    class Differ
      extend AttrExtras.mixin

      static_facade :diff, :actual, :expected

      def diff
        if worth_diffing?
          diff =
            SuperDiff::Differs::Main.call(expected, actual, omit_empty: true)
          pp diff: diff
          "\n\n" + diff
        else
          ""
        end
      rescue SuperDiff::Errors::NoDifferAvailableError => error
        puts "Got error: #{error}"
        ""
      end

      private

      def worth_diffing?
        pp comparing_inequal_values: comparing_inequal_values?,
           comparing_primitive_values: comparing_primitive_values?,
           comparing_singleline_strings: comparing_singleline_strings?

        comparing_inequal_values? && !comparing_primitive_values? &&
          !comparing_singleline_strings?
      end

      def comparing_inequal_values?
        !helpers.values_match?(expected, actual)
      end

      def comparing_primitive_values?
        expected.is_a?(Symbol) || expected.is_a?(Integer) ||
          [true, false, nil].include?(expected)
      end

      def comparing_singleline_strings?
        expected.is_a?(String) && actual.is_a?(String) &&
          !expected.include?("\n") && !actual.include?("\n")
      end

      def helpers
        @_helpers ||= Helpers.new
      end

      class Helpers
        include ::RSpec::Matchers::Composable

        public :values_match?
      end
    end
  end
end
