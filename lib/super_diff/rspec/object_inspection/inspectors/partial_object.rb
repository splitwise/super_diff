module SuperDiff
  module RSpec
    module ObjectInspection
      module Inspectors
        define :partial_object do
          add_text "#<an object having attributes ("

          nested do |aliased_matcher|
            insert_hash_inspection_of(
              aliased_matcher.expected,
              initial_break: nil,
            )
          end

          add_break
          add_text ")>"
        end
      end
    end
  end
end
