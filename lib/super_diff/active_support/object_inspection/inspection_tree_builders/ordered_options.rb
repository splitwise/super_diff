module SuperDiff
  module ActiveSupport
    module ObjectInspection
      module InspectionTreeBuilders
        class OrderedOptions < SuperDiff::ObjectInspection::InspectionTreeBuilders::Hash
          def self.applies_to?(value)
            value.is_a?(::ActiveSupport::OrderedOptions)
          end

          def call
            SuperDiff::ObjectInspection::InspectionTree.new do
              as_lines_when_rendering_to_lines(collection_bookend: :open) do
                add_text "#<OrderedOptions {"
              end

              when_rendering_to_string { add_text " " }

              nested do |ordered_options|
                insert_hash_inspection_of(ordered_options.to_hash)
              end

              when_rendering_to_string { add_text " " }

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
