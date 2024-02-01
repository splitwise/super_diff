module SuperDiff
  module RSpec
    module ObjectInspection
      module InspectionTreeBuilders
        class InstanceOf < SuperDiff::ObjectInspection::InspectionTreeBuilders::Base
          def self.applies_to?(value)
            SuperDiff::RSpec.an_instance_of_something?(value) ||
              SuperDiff::RSpec.instance_of_something?(value)
          end

          def call
            SuperDiff::ObjectInspection::InspectionTree.new do |t1|
              klass =
                if SuperDiff::RSpec.an_instance_of_something?(object)
                  object.expected
                else
                  object.instance_variable_get(:@klass)
                end

              t1.add_text "#<an instance of #{klass}>"
            end
          end
        end
      end
    end
  end
end
