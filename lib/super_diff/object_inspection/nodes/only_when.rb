module SuperDiff
  module ObjectInspection
    module Nodes
      class OnlyWhen < Base
        def self.node_name
          :only_when
        end

        def self.method_name
          :only_when
        end

        def initialize(tree, test, **options, &block)
          @tree = tree
          @test = test
          @block = block
          @options = options
        end

        def render_to_string(object)
          if test_passes?
            render_to_string_in_subtree(object)
          else
            ""
          end
        end

        def render_to_lines(object, type:, indentation_level:)
          if test_passes?
            render_to_lines_in_subtree(
              object,
              type: type,
              indentation_level: indentation_level,
            )
          else
            []
          end
        end

        private

        attr_reader :test

        def test_passes?
          if test.arity == 1
            test.call(object)
          else
            test.call
          end
        end
      end
    end
  end
end
