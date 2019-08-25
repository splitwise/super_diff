module SuperDiff
  module ObjectInspection
    class << self
      attr_accessor :inspector_registry
    end

    def self.inspect(object, single_line:, indent_level: 0)
      inspector_registry.find(object).evaluate(
        object,
        single_line: single_line,
        indent_level: indent_level,
      )
    end

    self.inspector_registry = InspectorRegistry.new
  end
end
