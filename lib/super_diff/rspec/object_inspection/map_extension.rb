module SuperDiff
  module RSpec
    module ObjectInspection
      module MapExtension
        def call(object)
          if SuperDiff::RSpec.a_hash_including_something?(object)
            Inspectors::HashIncluding
          elsif SuperDiff::RSpec.a_collection_including_something?(object)
            Inspectors::CollectionIncluding
          elsif SuperDiff::RSpec.an_object_having_some_attributes?(object)
            Inspectors::ObjectHavingAttributes
          elsif SuperDiff::RSpec.a_collection_containing_exactly_something?(object)
            Inspectors::CollectionContainingExactly
          elsif SuperDiff::RSpec.a_kind_of_something?(object)
            Inspectors::KindOf
          elsif SuperDiff::RSpec.an_instance_of_something?(object)
            Inspectors::InstanceOf
          elsif SuperDiff::RSpec.a_value_within_something?(object)
            Inspectors::ValueWithin
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
