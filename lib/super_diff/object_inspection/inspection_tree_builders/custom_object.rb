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
              add_text { |object| "#<#{object.class} " }

              when_rendering_to_lines { add_text "{" }
            end

            nested do |object|
              insert_hash_inspection_of(object.attributes_for_super_diff)
            end

            as_lines_when_rendering_to_lines(collection_bookend: :close) do
              when_rendering_to_lines { add_text "}" }

              add_text ">"
            end
          end
        end
      end
    end
  end
end
