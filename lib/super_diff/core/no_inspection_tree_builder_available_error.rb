# frozen_string_literal: true

module SuperDiff
  module Core
    class NoInspectionTreeBuilderAvailableError < StandardError
      def self.create(object)
        allocate.tap do |error|
          error.object = object
          error.__send__(:initialize)
        end
      end

      attr_accessor :object

      def initialize
        super(<<~MESSAGE)
          There is no inspection tree builder available to handle a "value" of type
          #{object.class}.
        MESSAGE
      end
    end
  end
end
