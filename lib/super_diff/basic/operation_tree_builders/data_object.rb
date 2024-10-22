# frozen_string_literal: true

module SuperDiff
  module Basic
    module OperationTreeBuilders
      class DataObject < CustomObject
        def self.applies_to?(expected, actual)
          SuperDiff::Core::Helpers.ruby_version_matches?('~> 3.2') &&
            expected.instance_of?(actual.class) && expected.is_a?(Data)
        end

        protected

        def attribute_names
          expected.members & actual.members
        end
      end
    end
  end
end
