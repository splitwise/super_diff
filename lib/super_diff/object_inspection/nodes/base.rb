module SuperDiff
  module ObjectInspection
    module Nodes
      class Base
        def initialize(tree, *args, &block)
          if !args.empty? && block
            raise ArgumentError.new(
              "You cannot provide both an immediate value and a lazy value. " +
              "Either pass a block or a positional argument.",
            )
          end

          @tree = tree
          @immediate_value = args.first
          @block = block
        end

        def clone_with(
          tree: @tree,
          immediate_value: @immediate_value,
          block: @block
        )
          if block
            self.class.new(tree, &block)
          else
            self.class.new(tree, immediate_value)
          end
        end

        def type
          self.class.name.
            sub(/^(.+)::(.+?)$/, '\2').
            gsub(/([a-z])([A-Z])/, '\1_\2').
            downcase.
            to_sym
        end

        # rubocop:disable Lint/UnusedMethodArgument
        def evaluate(object, indent_level:, single_line:)
        # rubocop:enable Lint/UnusedMethodArgument
          raise NotImplementedError.new(
            "Your node must provide an #evaluate method. " +
            "(Keep in mind #evaluate may be called more than once for a node!)",
          )
        end

        def pretty_print(pp)
          pp.object_address_group(self) do
            pp.seplist(pretty_print_variables, proc { pp.text "," }) do |name|
              value = instance_variable_get(name)
              pp.breakable " "
              pp.group(1) do
                pp.text name[1..-1].to_s
                pp.text ":"
                pp.breakable
                pp.pp value
              end
            end
          end
        end

        private

        attr_reader :tree, :immediate_value, :block

        def pretty_print_variables
          if block
            [:"@block"]
          else
            [:"@immediate_value"]
          end
        end

        def evaluate_in_subtree(object, indent_level:, single_line:)
          subtree = InspectionTree.new
          subtree.evaluate_block(object, &block)
          subtree.evaluate(
            object,
            indent_level: indent_level,
            single_line: single_line,
          )
        end
      end
    end
  end
end
