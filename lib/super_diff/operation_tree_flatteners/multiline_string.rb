module SuperDiff
  module OperationTreeFlatteners
    class MultilineString < Base
      def build_tiered_lines
        operation_tree.map do |operation|
          Line.new(
            type: operation.name,
            indentation_level: indentation_level,
            # TODO: Test that quotes and things don't get escaped but escape
            # characters do
            value: operation.value.inspect[1..-2].gsub(/\\"/, '"').gsub(/\\'/, "'")
          )
        end
      end
    end
  end
end
