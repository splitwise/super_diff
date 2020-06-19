require "forwardable"

module SuperDiff
  module OperationTrees
    class Base
      def self.applies_to?(*)
        unimplemented_class_method!
      end

      include Enumerable
      include ImplementationChecks
      extend ImplementationChecks
      extend Forwardable

      def_delegators :operations, :<<, :delete, :each

      def initialize(operations)
        @operations = operations
      end

      def to_diff(indentation_level:)
        TieredLinesFormatter.call(
          perhaps_elide(flatten(indentation_level: indentation_level)),
        )
      end

      def flatten(indentation_level:)
        operation_tree_flattener_class.call(
          self,
          indentation_level: indentation_level,
        )
      end

      def pretty_print(pp)
        pp.group(1, "#<#{self.class.name} [", "]>") do
          pp.breakable
          pp.seplist(self) do |value|
            pp.pp value
          end
        end
      end

      def perhaps_elide(tiered_lines)
        if SuperDiff.configuration.diff_elision_enabled?
          TieredLinesElider.call(tiered_lines)
        else
          tiered_lines
        end
      end

      private

      attr_reader :operations
    end
  end
end
