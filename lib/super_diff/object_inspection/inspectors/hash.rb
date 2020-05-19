module SuperDiff
  module ObjectInspection
    module Inspectors
      class Hash < Base
        def self.applies_to?(value)
          value.is_a?(::Hash)
        end

        protected

        def inspection_tree
          InspectionTree.new do
            when_empty do
              add_text "{}"
            end

            when_non_empty do
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
    end
  end
end
