module SuperDiff
  module RSpec
    module ObjectInspection
      module Inspectors
        class KindOf < SuperDiff::ObjectInspection::Inspectors::Base
          def self.applies_to?(value)
            SuperDiff::RSpec.a_kind_of_something?(value) || SuperDiff::RSpec.kind_of_something?(value)
          end

          protected

          def inspection_tree
            SuperDiff::ObjectInspection::InspectionTree.new do
              add_text do |value|
                klass = if SuperDiff::RSpec.a_kind_of_something?(value)
                          value.expected
                        else
                          value.instance_variable_get(:@klass)
                        end
                "#<a kind of #{klass}>"
              end
            end
          end
        end
      end
    end
  end
end
