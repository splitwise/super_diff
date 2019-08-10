module SuperDiff
  module ObjectInspection
    module Inspectors
      define :hash do
        add_text "{"

        nested do |hash|
          insert_hash_inspection_of(hash)
        end

        add_break " "
        add_text "}"
      end
    end
  end
end
