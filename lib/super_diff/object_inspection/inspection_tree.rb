module SuperDiff
  module ObjectInspection
    class InspectionTree
      include Enumerable

      def initialize(disallowed_node_names: [], &block)
        @disallowed_node_names = disallowed_node_names
        @nodes = []

        instance_eval(&block) if block
      end

      Nodes.registry.each do |node_class|
        define_method(node_class.method_name) do |*args, **options, &block|
          add_node(node_class, *args, **options, &block)
        end
      end

      def each(&block)
        nodes.each(&block)
      end

      def before_each_callbacks
        @_before_each_callbacks ||= Hash.new { |h, k| h[k] = [] }
      end

      def render_to_string(object)
        nodes.reduce("") do |string, node|
          result = node.render_to_string(object)
          string + result
        end
      end

      def render_to_lines(object, type:, indentation_level:)
        nodes
          .each_with_index
          .reduce(
            [TieredLines.new, "", ""]
          ) do |(tiered_lines, prelude, prefix), (node, index)|
            UpdateTieredLines.call(
              object: object,
              type: type,
              indentation_level: indentation_level,
              nodes: nodes,
              tiered_lines: tiered_lines,
              prelude: prelude,
              prefix: prefix,
              node: node,
              index: index
            )
          end
          .first
      end

      def evaluate_block(object, &block)
        instance_exec(object, &block)
      end

      def insert_array_inspection_of(array)
        insert_separated_list(array) do |value|
          # Have to do these shenanigans so that if value is a hash, Ruby
          # doesn't try to interpret it as keyword args
          if SuperDiff::Helpers.ruby_version_matches?(">= 2.7.1")
            add_inspection_of(value, **{})
          else
            add_inspection_of(*[value, {}])
          end
        end
      end

      def insert_hash_inspection_of(hash)
        keys = hash.keys

        format_keys_as_kwargs = keys.all? { |key| key.is_a?(Symbol) }

        insert_separated_list(keys) do |key|
          if format_keys_as_kwargs
            as_prefix_when_rendering_to_lines { add_text "#{key}: " }
          else
            as_prefix_when_rendering_to_lines do
              add_inspection_of key, as_lines: false
              add_text " => "
            end
          end

          # Have to do these shenanigans so that if hash[key] is a hash, Ruby
          # doesn't try to interpret it as keyword args
          if SuperDiff::Helpers.ruby_version_matches?(">= 2.7.1")
            add_inspection_of(hash[key], **{})
          else
            add_inspection_of(*[hash[key], {}])
          end
        end
      end

      def insert_separated_list(enumerable, &block)
        enumerable.each_with_index do |value, index|
          as_lines_when_rendering_to_lines(
            add_comma: index < enumerable.size - 1
          ) do
            when_rendering_to_string { add_text " " } if index > 0

            evaluate_block(value, &block)
          end
        end
      end

      private

      attr_reader :disallowed_node_names, :nodes

      def add_node(node_class, *args, **options, &block)
        if disallowed_node_names.include?(node_class.name)
          raise DisallowedNodeError.create(node_name: node_class.name)
        end

        append_node(build_node(node_class, *args, **options, &block))
      end

      def append_node(node)
        nodes.push(node)
      end

      def build_node(node_class, *args, **options, &block)
        node_class.new(self, *args, **options, &block)
      end

      class UpdateTieredLines
        extend AttrExtras.mixin

        method_object %i[
                        object!
                        type!
                        indentation_level!
                        nodes!
                        tiered_lines!
                        prelude!
                        prefix!
                        node!
                        index!
                      ]

        def call
          if rendering.is_a?(Array)
            concat_with_lines
          elsif rendering.is_a?(PrefixForNextNode)
            add_to_prefix
          elsif tiered_lines.any?
            add_to_last_line
          elsif index < nodes.size - 1 || rendering.is_a?(PreludeForNextNode)
            add_to_prelude
          else
            add_to_lines
          end
        end

        private

        def concat_with_lines
          additional_lines =
            prefix_with(prefix, prepend_with(prelude, rendering))
          [tiered_lines + additional_lines, "", ""]
        end

        def prefix_with(prefix, text)
          prefix.empty? ? text : [text[0].prefixed_with(prefix)] + text[1..-1]
        end

        def prepend_with(prelude, text)
          if prelude.empty?
            text
          else
            [text[0].with_value_prepended(prelude)] + text[1..-1]
          end
        end

        def add_to_prefix
          [tiered_lines, prelude, rendering + prefix]
        end

        def add_to_last_line
          new_lines =
            tiered_lines[0..-2] +
              [tiered_lines[-1].with_value_appended(rendering)]
          [new_lines, prelude, prefix]
        end

        def add_to_prelude
          [tiered_lines, prelude + rendering, prefix]
        end

        def add_to_lines
          new_lines =
            tiered_lines +
              [
                Line.new(
                  type: type,
                  indentation_level: indentation_level,
                  value: rendering
                )
              ]
          [new_lines, prelude, prefix]
        end

        def rendering
          if defined?(@_rendering)
            @_rendering
          else
            @_rendering =
              node.render(
                object,
                preferably_as_lines: true,
                type: type,
                indentation_level: indentation_level
              )
          end
        end
      end

      class DisallowedNodeError < StandardError
        def self.create(node_name:)
          allocate.tap do |error|
            error.node_name = node_name
            error.__send__(:initialize)
          end
        end

        attr_accessor :node_name

        def initialize(_message = nil)
          super("#{node_name} is not allowed to be used here!")
        end
      end
    end
  end
end
