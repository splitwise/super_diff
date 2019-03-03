module SuperDiff
  module RSpec
    class ValuesEqual
      def self.call(expected, actual)
        new(expected, actual).call
      end

      def initialize(expected, actual)
        @expected = expected
        @actual = actual
      end

      def call
        rspec_composable.values_match?(expected, actual)
      end

      private

      attr_reader :expected, :actual

      def rspec_composable
        @_rspec_composable ||= Object.new.tap do |object|
          object.singleton_class.class_eval do
            include ::RSpec::Matchers::Composable
            public :values_match?
          end
        end
      end
    end
  end
end
