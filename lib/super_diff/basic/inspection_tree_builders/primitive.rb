# frozen_string_literal: true

module SuperDiff
  module Basic
    module InspectionTreeBuilders
      class Primitive < Core::AbstractInspectionTreeBuilder
        def self.applies_to?(value)
          SuperDiff.primitive?(value)
        end

        def call
          Core::InspectionTree.new do |t1|
            t1.as_lines_when_rendering_to_lines do |t2|
              t2.add_text object.inspect
            end
          end
        end
      end
    end
  end
end
