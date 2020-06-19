module SuperDiff
  module ActiveSupport
    module ObjectInspection
      module InspectionTreeBuilders
        class HashWithIndifferentAccess < SuperDiff::ObjectInspection::InspectionTreeBuilders::Base
          def self.applies_to?(value)
            value.is_a?(::HashWithIndifferentAccess)
          end

          def call
            SuperDiff::ObjectInspection::InspectionTree.new do
              as_lines_when_rendering_to_lines(collection_bookend: :open) do
                add_text "#<HashWithIndifferentAccess {"
              end

              when_rendering_to_string do
                add_text " "
              end

              nested do |hash|
                insert_hash_inspection_of(hash)
              end

              when_rendering_to_string do
                add_text " "
              end

              as_lines_when_rendering_to_lines(collection_bookend: :close) do
                add_text "}>"
              end
            end
          end
        end
      end
    end
  end
end
