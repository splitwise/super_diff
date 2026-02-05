# frozen_string_literal: true

module SuperDiff
  module BinaryString
    module InspectionTreeBuilders
      class BinaryString < Core::AbstractInspectionTreeBuilder
        def self.applies_to?(value)
          SuperDiff::BinaryString.applies_to?(value)
        end

        def call
          Core::InspectionTree.new do |t|
            t.add_text "<binary string (#{object.bytesize} bytes)>"
          end
        end
      end
    end
  end
end
