module SuperDiff
  module Test
    class PersonOperationSequence < ::SuperDiff::OperationSequences::Base
      def to_diff(args)
        PersonDiffFormatter.call(self, args)
      end
    end
  end
end
