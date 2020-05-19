module SuperDiff
  module RSpec
    module ObjectInspection
      module Inspectors
        class KindOf < SuperDiff::ObjectInspection::Inspectors::Base
          def self.applies_to?(value)
            SuperDiff::RSpec.a_kind_of_something?(value)
          end

          protected

          def inspection_tree
            SuperDiff::ObjectInspection::InspectionTree.new do
              add_text do |aliased_matcher|
                "#<a kind of #{aliased_matcher.expected}>"
              end
            end
          end
        end
      end
    end
  end
end
