module SuperDiff
  module RSpec
    module ObjectInspection
      module Inspectors
        class Primitive < SuperDiff::ObjectInspection::Inspectors::Primitive
          def self.applies_to?(value)
            super || value.is_a?(::RSpec::Mocks::Double)
          end
        end
      end
    end
  end
end
