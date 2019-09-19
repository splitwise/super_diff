module SuperDiff
  module ActiveSupport
    module ObjectInspection
      module Inspectors
        HashWithIndifferentAccess = SuperDiff::ObjectInspection::InspectionTree.new do
          add_text "#<HashWithIndifferentAccess {"

          nested do |hash|
            insert_hash_inspection_of(hash)
          end

          add_break " "
          add_text "}>"
        end
      end
    end
  end
end
