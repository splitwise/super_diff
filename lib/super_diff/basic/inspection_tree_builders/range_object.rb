# frozen_string_literal: true

module SuperDiff
  module Basic
    module InspectionTreeBuilders
      class RangeObject < Core::AbstractInspectionTreeBuilder
        def self.applies_to?(value)
          value.is_a?(Range)
        end

        def call
          Core::InspectionTree.new do |t1|
            t1.as_lines_when_rendering_to_lines { |t2| t2.add_text object.to_s }
          end
        end
      end
    end
  end
end
