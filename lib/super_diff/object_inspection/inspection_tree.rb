module SuperDiff
  module ObjectInspection
    class InspectionTree
      include Enumerable

      def initialize(&block)
        @nodes = []

        if block
          instance_eval(&block)
        end
      end

      def each(&block)
        nodes.each(&block)
      end

      def before_each_callbacks
        @_before_each_callbacks ||= Hash.new { |h, k| h[k] = [] }
      end

      def evaluate(object, single_line:, indent_level:)
        nodes.reduce("") do |str, node|
          str << node.evaluate(
            object,
            single_line: single_line,
            indent_level: indent_level,
          )
        end
      end

      def evaluate_block(object, &block)
        instance_exec(object, &block)
      end

      def add_text(*args, &block)
        add_node :text, *args, &block
      end

      def when_multiline(&block)
        add_node :when_multiline, &block
      end

      def when_singleline(&block)
        add_node :when_singleline, &block
      end

      def add_break(*args, &block)
        add_node :break, *args, &block
      end

      def nested(&block)
        add_node :nesting, &block
      end

      def insert_array_inspection_of(array)
        # FIXME: why must this be inside the `nested`?
        add_break

        insert_separated_list(array) do |value|
          add_inspection_of value
        end
      end

      def insert_hash_inspection_of(hash, initial_break: " ")
        # FIXME: why must this be inside the `nested`?
        add_break initial_break

        format_keys_as_kwargs = hash.keys.all? do |key|
          key.is_a?(Symbol)
        end

        insert_separated_list(hash) do |(key, value)|
          if format_keys_as_kwargs
            add_text key
            add_text ": "
          else
            add_inspection_of key
            add_text " => "
          end

          add_inspection_of value
        end
      end

      def insert_separated_list(enumerable, separator: ",")
        enumerable.each_with_index do |value, index|
          if index > 0
            if separator.is_a?(Nodes::Base)
              append_node separator
            else
              add_text separator
            end

            add_break " "
          end

          yield value
        end
      end

      def add_inspection_of(value)
        add_node :inspection, value
      end

      def apply_tree(tree)
        tree.each do |node|
          append_node(node.clone_with(tree: self))
        end
      end

      private

      attr_reader :nodes

      def add_node(type, *args, &block)
        append_node(build_node(type, *args, &block))
      end

      def append_node(node)
        nodes.push(node)
      end

      def build_node(type, *args, &block)
        Nodes.fetch(type).new(self, *args, &block)
      end

      class BlockArgument
        attr_reader :object

        def initialize(object:, single_line:)
          @object = object
          @single_line = single_line
        end

        def single_line?
          @single_line
        end
      end
    end
  end
end
