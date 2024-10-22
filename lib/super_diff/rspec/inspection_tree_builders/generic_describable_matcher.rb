# frozen_string_literal: true

module SuperDiff
  module RSpec
    module InspectionTreeBuilders
      class GenericDescribableMatcher < Core::AbstractInspectionTreeBuilder
        def self.applies_to?(value)
          ::RSpec::Matchers.is_a_describable_matcher?(value)
        end

        def call
          Core::InspectionTree.new do |t1|
            t1.add_text "#<#{object.description}>"
          end
        end
      end
    end
  end
end
