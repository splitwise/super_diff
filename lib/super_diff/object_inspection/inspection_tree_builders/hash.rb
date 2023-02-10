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
              as_lines_when_rendering_to_lines { add_text "{}" }
            end

            only_when nonempty do
              as_lines_when_rendering_to_lines(collection_bookend: :open) do
                add_text "{"
              end

              when_rendering_to_string { add_text " " }

              nested { |hash| insert_hash_inspection_of(hash) }

              when_rendering_to_string { add_text " " }

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
