module SuperDiff
  module ObjectInspection
    module Nodes
      autoload :Base, "super_diff/object_inspection/nodes/base"
      autoload :Break, "super_diff/object_inspection/nodes/break"
      autoload :Inspection, "super_diff/object_inspection/nodes/inspection"
      autoload :Nesting, "super_diff/object_inspection/nodes/nesting"
      autoload :Text, "super_diff/object_inspection/nodes/text"
      autoload(
        :WhenMultiline,
        "super_diff/object_inspection/nodes/when_multiline",
      )
      autoload(
        :WhenSingleline,
        "super_diff/object_inspection/nodes/when_singleline",
      )

      def self.fetch(type)
        registry.fetch(type) do
          raise KeyError, "Could not find a node class for #{type.inspect}!"
        end
      end

      def self.registry
        @_registry ||= {
          break: Break,
          inspection: Inspection,
          nesting: Nesting,
          text: Text,
          when_multiline: WhenMultiline,
          when_singleline: WhenSingleline,
        }
      end
    end
  end
end
