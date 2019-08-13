module SuperDiff
  module ObjectInspection
    def self.inspect(object, single_line:, indent_level: 0)
      Inspectors.find(object).evaluate(
        object,
        single_line: single_line,
        indent_level: indent_level
      )
    end
  end
end
