module SuperDiff
  module RSpec
    module ObjectInspection
      module Inspectors
        define :collection_containing_exactly do
          add_text "#<a collection containing exactly ("

          nested do |aliased_matcher|
            insert_array_inspection_of(aliased_matcher.expected)
          end

          add_break
          add_text ")>"
        end
      end
    end
  end
end
