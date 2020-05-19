module SuperDiff
  module ActiveSupport
    module ObjectInspection
      module Inspectors
        class HashWithIndifferentAccess < SuperDiff::ObjectInspection::Inspectors::Base
          def self.applies_to?(value)
            value.is_a?(::HashWithIndifferentAccess)
          end

          protected

          def inspection_tree
            SuperDiff::ObjectInspection::InspectionTree.new do
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
  end
end
