# frozen_string_literal: true

module SuperDiff
  module Basic
    module OperationTrees
      class DefaultObject < Core::AbstractOperationTree
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
            pp.text ':operations=>'
            pp.group(1, '[', ']') do
              pp.breakable
              pp.seplist(self) { |value| pp.pp value }
            end
            pp.comma_breakable
            pp.text ':underlying_object=>'
            pp.object_address_group underlying_object do
              # do nothing
            end
          end
          pp.text '>'
        end

        protected

        def operation_tree_flattener_class
          OperationTreeFlatteners::DefaultObject
        end
      end
    end
  end
end
