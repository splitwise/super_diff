module SuperDiff
  module ObjectInspection
    module InspectionTreeBuilders
      class Hash < Base
        def self.applies_to?(value)
          value.is_a?(::Hash)
        end

        def call
          empty = -> { object.empty? }
          nonempty = -> { !object.empty? }

          InspectionTree.new do
            only_when empty do
              as_lines_when_rendering_to_lines do
                add_text "{}"
              end
            end

            only_when nonempty do
              as_lines_when_rendering_to_lines(collection_bookend: :open) do
                add_text "{"
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
                add_text "}"
              end
            end
          end
        end
      end
    end
  end
end
