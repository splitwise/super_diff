module SuperDiff
  module ObjectInspection
    module InspectionTreeBuilders
      class CustomObject < Base
        def self.applies_to?(value)
          value.respond_to?(:attributes_for_super_diff)
        end

        def call
          InspectionTree.new do
            as_lines_when_rendering_to_lines(collection_bookend: :open) do
              add_text do |object|
                "#<#{object.class} "
              end

              when_rendering_to_lines do
                add_text "{"
              end
            end

            nested do |object|
              insert_hash_inspection_of(object.attributes_for_super_diff)
            end

            as_lines_when_rendering_to_lines(collection_bookend: :close) do
              when_rendering_to_lines do
                add_text "}"
              end

              add_text ">"
            end
          end
        end
      end
    end
  end
end
