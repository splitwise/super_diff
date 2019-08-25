module SuperDiff
  module RSpec
    module ObjectInspection
      module Inspectors
        define :partial_array do
          add_text "#<a collection including ("

          nested do |aliased_matcher|
            insert_array_inspection_of(aliased_matcher.expecteds)
          end

          add_break
          add_text ")>"
        end
      end
    end
  end
end
