module SuperDiff
  module Test
    class PersonOperationSequence < ::SuperDiff::OperationSequences::Base
      def to_diff(indent_level:, collection_prefix:, add_comma:)
        PersonDiffFormatter.call(
          self,
          indent_level: indent_level,
          collection_prefix: collection_prefix,
          add_comma: add_comma
        )
      end
    end
  end
end
