# frozen_string_literal: true

module SuperDiff
  module RSpec
    class Differ
      extend AttrExtras.mixin

      static_facade :diff, :actual, :expected

      def diff
        if worth_diffing?
          diff = SuperDiff.diff(expected, actual)
          "\n\n#{diff}"
        else
          ''
        end
      rescue Core::NoDifferAvailableError
        ''
      end

      private

      def worth_diffing?
        comparing_inequal_values? && !comparing_primitive_values? &&
          !comparing_proc_values? && !comparing_singleline_strings?
      end

      def comparing_inequal_values?
        !helpers.values_match?(expected, actual)
      end

      def comparing_primitive_values?
        # strings are indeed primitives, but we still may want to diff them if
        # they are multiline strings (see #comparing_singleline_strings?)
        return false if expected.is_a?(String)

        SuperDiff.primitive?(expected)
      end

      def comparing_proc_values?
        expected.is_a?(Proc)
      end

      def comparing_singleline_strings?
        return false if comparing_binary_strings?

        expected.is_a?(String) && actual.is_a?(String) &&
          !expected.include?("\n") && !actual.include?("\n")
      end

      def comparing_binary_strings?
        defined?(BinaryString) && BinaryString.applies_to?(expected, actual)
      end

      def helpers
        @helpers ||= RSpecHelpers.new
      end

      class RSpecHelpers
        include ::RSpec::Matchers::Composable

        public :values_match?
      end
    end
  end
end
