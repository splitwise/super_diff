module SuperDiff
  module RSpec
    module ObjectInspection
      module Inspectors
        class InstanceOf < SuperDiff::ObjectInspection::Inspectors::Base
          def self.applies_to?(value)
            SuperDiff::RSpec.an_instance_of_something?(value) || SuperDiff::RSpec.instance_of_something?(value)
          end

          protected

          def inspection_tree
            SuperDiff::ObjectInspection::InspectionTree.new do
              add_text do |value|
                klass = if SuperDiff::RSpec.an_instance_of_something?(value)
                          value.expected
                        else
                          value.instance_variable_get(:@klass)
                        end
                "#<an instance of #{klass}>"
              end
            end
          end
        end
      end
    end
  end
end
