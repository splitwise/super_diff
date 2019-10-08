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
          elsif object.is_a?(::RSpec::Mocks::Double)
            SuperDiff::ObjectInspection::Inspectors::Primitive
          elsif object.is_a?(::RSpec::Mocks::ArgumentMatchers::ArrayIncludingMatcher)
            Inspectors::ArrayIncludingArgument
          elsif object.is_a?(::RSpec::Mocks::ArgumentMatchers::DuckTypeMatcher)
            Inspectors::DuckTypeArgument
          elsif object.is_a?(::RSpec::Mocks::ArgumentMatchers::HashExcludingMatcher)
            Inspectors::HashExcludingArgument
          elsif object.is_a?(::RSpec::Mocks::ArgumentMatchers::HashIncludingMatcher)
            Inspectors::HashIncludingArgument
          elsif object.is_a?(::RSpec::Mocks::ArgumentMatchers::KindOf)
            Inspectors::KindOfArgument
          elsif matcher?(object)
            Inspectors::Matcher
          else
            super
          end
        end

        private

        def matcher?(object)
          ::RSpec::Support.is_a_matcher?(object) &&
            object.respond_to?(:description)
        end
      end
    end
  end
end
