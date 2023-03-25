module SuperDiff
  module ActiveRecord
    module ObjectInspection
      module InspectionTreeBuilders
        class ActiveRecordRelation < SuperDiff::ObjectInspection::InspectionTreeBuilders::Base
          def self.applies_to?(value)
            value.is_a?(::ActiveRecord::Relation)
          end

          def call
            SuperDiff::ObjectInspection::InspectionTree.new do
              as_lines_when_rendering_to_lines(collection_bookend: :open) do
                add_text "#<ActiveRecord::Relation ["
              end

              nested { |array| insert_array_inspection_of(array) }

              as_lines_when_rendering_to_lines(collection_bookend: :close) do
                add_text "]>"
              end
            end
          end
        end
      end
    end
  end
end
