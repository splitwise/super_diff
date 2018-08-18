module SuperDiff
  module DiffFormatters
    class Base
      def self.applies_to?(operations)
        raise NotImplementedError
      end

      def self.call(*args)
        new(*args).call
      end

      def initialize(
        operations,
        indent_level:,
        collection_prefix: "",
        add_comma: false
      )
        @operations = operations
        @indent_level = indent_level
        @collection_prefix = collection_prefix
        @add_comma = add_comma
      end

      def call
        raise NotImplementedError
      end

      private

      attr_reader :operations, :indent_level, :collection_prefix

      def add_comma?
        @add_comma
      end
    end
  end
end
