module SuperDiff
  module RSpec
    module ObjectInspection
      module Inspectors
        KindOf = SuperDiff::ObjectInspection::InspectionTree.new do
          add_text do |aliased_matcher|
            "#<a kind of #{aliased_matcher.expected}>"
          end
        end
      end
    end
  end
end
