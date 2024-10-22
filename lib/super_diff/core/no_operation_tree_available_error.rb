# frozen_string_literal: true

module SuperDiff
  module Core
    class NoOperationTreeAvailableError < StandardError
      def self.create(value)
        allocate.tap do |error|
          error.value = value
          error.__send__(:initialize)
        end
      end

      attr_accessor :value

      def initialize
        super(<<~MESSAGE)
          There is no operation tree available to handle a "value" of type #{value.class}.
        MESSAGE
      end
    end
  end
end
