module SuperDiff
  module ObjectInspection
    module Nodes
      autoload :Base, "super_diff/object_inspection/nodes/base"
      autoload :Break, "super_diff/object_inspection/nodes/break"
      autoload :Inspection, "super_diff/object_inspection/nodes/inspection"
      autoload :Nesting, "super_diff/object_inspection/nodes/nesting"
      autoload :Text, "super_diff/object_inspection/nodes/text"
      autoload(
        :WhenEmpty,
        "super_diff/object_inspection/nodes/when_empty",
      )
      autoload(
        :WhenMultiline,
        "super_diff/object_inspection/nodes/when_multiline",
      )
      autoload(
        :WhenNonEmpty,
        "super_diff/object_inspection/nodes/when_non_empty",
      )
      autoload(
        :WhenSingleline,
        "super_diff/object_inspection/nodes/when_singleline",
      )

      def self.fetch(type)
        registry.fetch(type) do
          raise(
            KeyError,
            "#{type.inspect} is not included in ObjectInspection::Nodes.registry!",
          )
        end
      end

      def self.registry
        @_registry ||= {
          break: Break,
          inspection: Inspection,
          nesting: Nesting,
          text: Text,
          when_empty: WhenEmpty,
          when_multiline: WhenMultiline,
          when_non_empty: WhenNonEmpty,
          when_singleline: WhenSingleline,
        }
      end
    end
  end
end
