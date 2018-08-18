module SuperDiff
  class DiffFormatter
    def self.call(*args)
      raise "We don't need this anymore"
      new(*args).call
    end

    def initialize(
      operations,
      indent_level:,
      add_comma: false,
      extra_classes: []
    )
      @operations = operations
      @indent_level = indent_level
      @add_comma = add_comma
      @extra_classes = extra_classes
    end

    def call
      resolved_class.call(
        operations,
        indent_level: indent_level,
        add_comma: add_comma
      )
    end

    private

    attr_reader :operations, :indent_level, :add_comma, :extra_classes

    def resolved_class
      (DiffFormatters::DEFAULTS + extra_classes).detect do |klass|
        klass.applies_to?(operations)
      end
    end
  end
end
