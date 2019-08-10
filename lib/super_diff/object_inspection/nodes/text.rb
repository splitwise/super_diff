module SuperDiff
  module ObjectInspection
    module Nodes
      class Text < Base
        def evaluate(object, **)
          if block
            tree.instance_exec(object, &block).to_s
          else
            immediate_value.to_s
          end
        end
      end

      register :text, Text
    end
  end
end
