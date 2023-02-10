module SuperDiff
  module RSpec
    module OperationTreeBuilders
      class ObjectHavingAttributes < SuperDiff::OperationTreeBuilders::DefaultObject
        def self.applies_to?(expected, _actual)
          SuperDiff::RSpec.an_object_having_some_attributes?(expected)
        end

        protected

        def build_operation_tree
          find_operation_tree_for(actual)
        end

        def attribute_names
          if actual.respond_to?(:attributes_for_super_diff)
            actual.attributes_for_super_diff.keys | expected.expected.keys
          else
            expected.expected.keys
          end
        end

        private

        def establish_expected_and_actual_attributes
          @expected_attributes =
            attribute_names.reduce({}) do |hash, name|
              if expected.expected.include?(name)
                hash.merge(name => expected.expected[name])
              else
                hash
              end
            end

          @actual_attributes =
            attribute_names.reduce({}) do |hash, name|
              if actual.respond_to?(name)
                hash.merge(name => actual.public_send(name))
              else
                hash
              end
            end
        end

        def should_add_noop_operation?(attribute_name)
          !expected_attributes.include?(attribute_name) ||
            (
              actual_attributes.include?(attribute_name) &&
                expected_attributes[attribute_name] ==
                  actual_attributes[attribute_name]
            )
        end

        def should_add_insert_operation?(attribute_name)
          expected_attributes.include?(attribute_name) &&
            actual_attributes.include?(attribute_name) &&
            expected_attributes[attribute_name] !=
              actual_attributes[attribute_name]
        end
      end
    end
  end
end
