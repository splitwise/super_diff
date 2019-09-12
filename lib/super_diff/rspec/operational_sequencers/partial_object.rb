module SuperDiff
  module RSpec
    module OperationalSequencers
      class PartialObject < SuperDiff::OperationalSequencers::DefaultObject
        def self.applies_to?(expected, _actual)
          SuperDiff::RSpec.partial_object?(expected)
        end

        protected

        def build_operation_sequencer
          # TODO: Test this
          if actual.respond_to?(:attributes_for_super_diff)
            OperationSequences::CustomObject.new([], value_class: actual.class)
          else
            OperationSequences::DefaultObject.new([], value_class: actual.class)
          end
        end

        def attribute_names
          # TODO: Test this
          if actual.respond_to?(:attributes_for_super_diff)
            actual.attributes_for_super_diff.keys | expected.expected.keys
          else
            expected.expected.keys
          end
        end

        private

        def establish_expected_and_actual_attributes
          @expected_attributes = attribute_names.reduce({}) do |hash, name|
            if expected.expected.include?(name)
              hash.merge(name => expected.expected[name])
            else
              hash
            end
          end

          @actual_attributes = attribute_names.reduce({}) do |hash, name|
            if actual.respond_to?(name)
              hash.merge(name => actual.public_send(name))
            else
              hash
            end
          end
        end

        def should_add_noop_operation?(attribute_name)
          !expected_attributes.include?(attribute_name) || (
            actual_attributes.include?(attribute_name) &&
            expected_attributes[attribute_name] == actual_attributes[attribute_name]
          )
        end

        def should_add_insert_operation?(attribute_name)
          expected_attributes.include?(attribute_name) &&
            actual_attributes.include?(attribute_name) &&
            expected_attributes[attribute_name] != actual_attributes[attribute_name]
        end
      end
    end
  end
end
