module SuperDiff
  module Basic
    module OperationTreeBuilders
      class DataObject < CustomObject
        def self.applies_to?(expected, actual)
          return false unless SuperDiff::Core::Helpers.ruby_version_matches?('~> 3.2')

          expected.class == actual.class &&
            expected.is_a?(Data) && actual.is_a?(Data)
        end

        protected

        def attribute_names
          expected.members & actual.members
        end
      end
    end
  end
end
