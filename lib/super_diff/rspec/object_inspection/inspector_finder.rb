module SuperDiff
  module RSpec
    module ObjectInspection
      class InspectorFinder < SuperDiff::ObjectInspection::InspectorFinder
        def self.call(object)
          if SuperDiff::RSpec.partial_hash?(object)
            Inspectors::PartialHash
          elsif SuperDiff::RSpec.partial_array?(object)
            Inspectors::PartialArray
          elsif SuperDiff::RSpec.partial_object?(object)
            Inspectors::PartialObject
          elsif SuperDiff::RSpec.collection_containing_exactly?(object)
            Inspectors::CollectionContainingExactly
          elsif object.is_a?(::RSpec::Mocks::Double)
            SuperDiff::ObjectInspection::Inspectors::Primitive
          else
            super
          end
        end
      end
    end
  end
end
