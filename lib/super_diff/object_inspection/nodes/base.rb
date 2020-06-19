module SuperDiff
  module ObjectInspection
    module Nodes
      class Base
        def self.node_name
          unimplemented_class_method!
        end

        def self.method_name
          unimplemented_class_method!
        end

        include ImplementationChecks
        extend ImplementationChecks

        def initialize(tree, *args, **options, &block)
          if !args.empty? && block
            raise ArgumentError.new(
              "You cannot provide both an immediate value and a lazy value. " +
              "Either pass a block or a positional argument.",
            )
          end

          @tree = tree
          @immediate_value = args.first
          @block = block
          @options = options
        end

        def clone_with(
          tree: @tree,
          immediate_value: @immediate_value,
          block: @block,
          **rest
        )
          if block
            self.class.new(tree, **options, **rest, &block)
          else
            self.class.new(tree, immediate_value, **options, **rest)
          end
        end

        def render(object, preferably_as_lines:, **rest)
          if options[:as_lines] || preferably_as_lines
            render_to_lines(object, **rest)
          else
            render_to_string(object)
          end
        end

        # rubocop:disable Lint/UnusedMethodArgument
        def render_to_string(object)
        # rubocop:enable Lint/UnusedMethodArgument
          unimplemented_instance_method!
        end

        # rubocop:disable Lint/UnusedMethodArgument
        def render_to_lines(object, type:, indentation_level:)
        # rubocop:enable Lint/UnusedMethodArgument
          unimplemented_instance_method!
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

        attr_reader :tree, :immediate_value, :block, :options

        def pretty_print_variables
          if block
            [:"@block"]
          else
            [:"@immediate_value"]
          end
        end

        def evaluate_block(object)
          tree.evaluate_block(object, &block)
        end

        def render_to_string_in_subtree(object)
          subtree = InspectionTree.new
          subtree.evaluate_block(object, &block)
          subtree.render_to_string(object)
        end

        def render_to_lines_in_subtree(
          object,
          type:,
          indentation_level:,
          disallowed_node_names: [],
          **rest
        )
          subtree = InspectionTree.new(
            disallowed_node_names: disallowed_node_names,
          )
          subtree.evaluate_block(object, &block)
          subtree.render_to_lines(
            object,
            type: type,
            indentation_level: indentation_level,
            **rest,
          )
        end
      end
    end
  end
end
