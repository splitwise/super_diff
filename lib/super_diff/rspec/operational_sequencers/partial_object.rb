module SuperDiff
  module RSpec
    module OperationalSequencers
      class PartialObject < SuperDiff::OperationalSequencers::Object
        def self.applies_to?(expected, _actual)
          SuperDiff::RSpec.partial_object?(expected)
        end

        protected

        def build_operation_sequencer
          OperationSequences::Object.new([], value_class: actual.class)
        end

        def attribute_names
          expected.expected.keys# & actual.methods
        end

        private

        def establish_expected_and_actual_attributes
          @expected_attributes = attribute_names.reduce({}) do |hash, name|
            hash.merge(name => expected.expected[name])
          end

          @actual_attributes = attribute_names.reduce({}) do |hash, name|
            if actual.respond_to?(name)
              hash.merge(name => actual.public_send(name))
            else
              hash
            end
          end
        end

=begin
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
=end
      end
    end
  end
end
