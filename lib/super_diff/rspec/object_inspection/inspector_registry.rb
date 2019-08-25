module SuperDiff
  module RSpec
    module ObjectInspection
      class InspectorRegistry < SuperDiff::ObjectInspection::InspectorRegistry
        private

        def type_for(object)
          if SuperDiff::RSpec.partial_hash?(object)
            :partial_hash
          elsif SuperDiff::RSpec.partial_array?(object)
            :partial_array
          else
            super
          end
        end
      end
    end
  end
end
