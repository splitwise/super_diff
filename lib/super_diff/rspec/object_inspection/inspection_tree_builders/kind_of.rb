module SuperDiff
  module RSpec
    module ObjectInspection
      module InspectionTreeBuilders
        class KindOf < SuperDiff::ObjectInspection::InspectionTreeBuilders::Base
          def self.applies_to?(value)
            SuperDiff::RSpec.a_kind_of_something?(value) ||
              SuperDiff::RSpec.kind_of_something?(value)
          end

          def call
            SuperDiff::ObjectInspection::InspectionTree.new do |t1|
              klass =
                if SuperDiff::RSpec.a_kind_of_something?(object)
                  object.expected
                else
                  object.instance_variable_get(:@klass)
                end

              t1.add_text "#<a kind of #{klass}>"
            end
          end
        end
      end
    end
  end
end
