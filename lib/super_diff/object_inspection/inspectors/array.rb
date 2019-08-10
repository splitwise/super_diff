module SuperDiff
  module ObjectInspection
    module Inspectors
      define :array do
        add_text "["

        nested do |array|
          add_break

          insert_separated_list(array) do |value|
            add_inspection_of value
          end
        end

        add_break
        add_text "]"
      end
    end
  end
end
