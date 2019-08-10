module SuperDiff
  module ObjectInspection
    def self.inspect(
      object,
      single_line:,
      indent_level: 0,
      overall_prefix: nil,
      line_prefix: nil
    )
      InspectionTreeEvaluator.call(
        Inspectors.find(object),
        object,
        single_line: single_line,
        indent_level: indent_level,
        overall_prefix: overall_prefix,
        line_prefix: line_prefix,
      )
    end
  end
end
