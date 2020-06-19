module SuperDiff
  module OperationTrees
    class DefaultObject < Base
      def self.applies_to?(*)
        true
      end

      attr_reader :underlying_object

      def initialize(operations, underlying_object:)
        super(operations)
        @underlying_object = underlying_object
      end

      def pretty_print(pp)
        pp.text "#<#{self.class.name} "
        pp.nest(1) do
          pp.breakable
          pp.text ":operations=>"
          pp.group(1, "[", "]") do
            pp.breakable
            pp.seplist(self) do |value|
              pp.pp value
            end
          end
          pp.comma_breakable
          pp.text ":underlying_object=>"
          pp.object_address_group underlying_object do
            # do nothing
          end
        end
        pp.text ">"
      end

      protected

      def operation_tree_flattener_class
        OperationTreeFlatteners::DefaultObject
      end
    end
  end
end
