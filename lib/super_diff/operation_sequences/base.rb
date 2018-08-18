module SuperDiff
  module OperationSequences
    class Base < SimpleDelegator
      def to_diff(indent_level:, add_comma:, collection_prefix: nil)
        raise NotImplementedError
      end
    end
  end
end
