module SuperDiff
  module ObjectInspection
    module Nodes
      class Text < Base
        def self.node_name
          :text
        end

        def self.method_name
          :add_text
        end

        def render_to_string(object)
          block ? evaluate_block(object).to_s : immediate_value.to_s
        end

        def render_to_lines(object, **)
          # NOTE: This is a bit of a hack since it returns a string instead of a
          # Line, but it is handled in InspectionTree (see UpdateTieredLines)
          render_to_string(object)
        end
      end
    end
  end
end
