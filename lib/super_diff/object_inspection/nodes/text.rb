module SuperDiff
  module ObjectInspection
    module Nodes
      class Text < Base
        def evaluate(object, **)
          if block
            tree.evaluate_block(object, &block).to_s
          else
            immediate_value.to_s
          end
        end
      end
    end
  end
end
