module SuperDiff
  module RSpec
    module ObjectInspection
      module InspectionTreeBuilders
        class RSpecMatcher < SuperDiff::ObjectInspection::InspectionTreeBuilders::Base
          def self.applies_to?(value)
            value.is_a?(::RSpec::Matchers::BuiltIn::BaseMatcher) ||
              value.is_a?(::RSpec::Matchers::DSL::Matcher)
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
