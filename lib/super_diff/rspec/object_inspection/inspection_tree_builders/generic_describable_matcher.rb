module SuperDiff
  module RSpec
    module ObjectInspection
      module InspectionTreeBuilders
        class GenericDescribableMatcher < SuperDiff::ObjectInspection::InspectionTreeBuilders::Base
          def self.applies_to?(value)
            ::RSpec::Matchers.is_a_describable_matcher?(value)
          end

          def call
            SuperDiff::ObjectInspection::InspectionTree.new do |t1|
              t1.add_text "#<#{object.description}>"
            end
          end
        end
      end
    end
  end
end
