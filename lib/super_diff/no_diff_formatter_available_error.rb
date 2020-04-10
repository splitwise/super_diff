module SuperDiff
  class NoDiffFormatterAvailableError < StandardError
    def self.create(operations)
      allocate.tap do |error|
        error.operations = operations
        error.__send__(:initialize)
      end
    end

    attr_accessor :operations

    def initialize
      super(<<-MESSAGE)
There is no diff formatter available to handle an operations object of
#{operations.class}.
      MESSAGE
    end
  end
end
