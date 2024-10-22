# frozen_string_literal: true

module SuperDiff
  module RSpec
    module InspectionTreeBuilders
      class ValueWithin < Core::AbstractInspectionTreeBuilder
        def self.applies_to?(value)
          SuperDiff::RSpec.a_value_within_something?(value)
        end

        def call
          Core::InspectionTree.new do |t1|
            t1.as_prelude_when_rendering_to_lines do |t2|
              t2.add_text '#<a value within '

              t2.add_inspection_of(
                object.base_matcher.instance_variable_get('@delta'),
                as_lines: false
              )

              t2.add_text ' of '
            end

            t1.add_inspection_of object.expected

            t1.add_text '>'
          end
        end
      end
    end
  end
end
