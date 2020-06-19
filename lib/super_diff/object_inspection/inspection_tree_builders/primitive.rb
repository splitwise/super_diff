module SuperDiff
  module ObjectInspection
    module InspectionTreeBuilders
      class Primitive < Base
        def self.applies_to?(value)
          SuperDiff.primitive?(value) || value.is_a?(::String)
        end

        def call
          InspectionTree.new do
            as_lines_when_rendering_to_lines do
              # rubocop:disable Style/SymbolProc
              add_text { |object| object.inspect }
              # rubocop:enable Style/SymbolProc
            end
          end
        end
      end
    end
  end
end
