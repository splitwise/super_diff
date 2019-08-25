module SuperDiff
  module ObjectInspection
    module Inspectors
      define :array do
        add_text "["

        nested do |array|
          insert_array_inspection_of(array)
        end

        add_break
        add_text "]"
      end
    end
  end
end
