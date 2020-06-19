module SuperDiff
  module RSpec
    module ObjectInspection
      module InspectionTreeBuilders
        class ValueWithin < SuperDiff::ObjectInspection::InspectionTreeBuilders::Base
          def self.applies_to?(value)
            SuperDiff::RSpec.a_value_within_something?(value)
          end

          def call
            SuperDiff::ObjectInspection::InspectionTree.new do
              as_prelude_when_rendering_to_lines do
                add_text "#<a value within "

                add_inspection_of as_lines: false do |aliased_matcher|
                  aliased_matcher.base_matcher.instance_variable_get("@delta")
                end

                add_text " of "
              end

              # rubocop:disable Style/SymbolProc
              add_inspection_of { |aliased_matcher| aliased_matcher.expected }
              # rubocop:enable Style/SymbolProc

              add_text ">"
            end
          end
        end
      end
    end
  end
end
