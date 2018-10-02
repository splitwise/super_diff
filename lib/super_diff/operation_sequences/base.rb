module SuperDiff
  module OperationSequences
    class Base < SimpleDelegator
      # rubocop:disable Lint/UnusedMethodArgument
      def to_diff(indent_level:, add_comma:, collection_prefix: nil)
        raise NotImplementedError
      end
      # rubocop:enable Lint/UnusedMethodArgument
    end
  end
end
