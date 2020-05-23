module SuperDiff
  module Errors
    class NoDiffFormatterAvailableError < StandardError
      def self.create(operation_tree)
        allocate.tap do |error|
          error.operation_tree = operation_tree
          error.__send__(:initialize)
        end
      end

      attr_accessor :operation_tree

      def initialize
        super(<<-MESSAGE)
There is no diff formatter available to handle an operation tree object of
#{operation_tree.class}.
        MESSAGE
      end
    end
  end
end
