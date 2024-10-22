# frozen_string_literal: true

module SuperDiff
  module UnitTests
    def be_deprecated_in_favor_of(new_constant_name)
      BeDeprecatedInFavorOfMatcher.new(new_constant_name)
    end

    class BeDeprecatedInFavorOfMatcher
      extend AttrExtras.mixin

      pattr_initialize :new_constant_name
      attr_private :actual_output, :old_constant_name

      def matches?(old_constant_name)
        @old_constant_name = old_constant_name
        @actual_output =
          SuperDiff::UnitTests.capture_warnings do
            Object.const_get(old_constant_name)
          end
        @actual_output.start_with?(expected_prefix)
      end

      def failure_message
        'Expected stderr to start with:' \
          "\n\n#{SuperDiff::Test::OutputHelpers.bookended(expected_prefix)}" \
          "\nActual output:" \
          "\n\n#{SuperDiff::Test::OutputHelpers.bookended(actual_output)}"
      end

      private

      def expected_prefix
        <<~WARNING.rstrip
          WARNING: #{old_constant_name} is deprecated and will be removed in the next major release.
          Please use #{new_constant_name} instead.
        WARNING
      end
    end
  end
end
