module SuperDiff
  module ObjectInspection
    module Inspectors
      class String < Base
        def self.applies_to?(value)
          value.is_a?(::String)
        end

        protected

        def inspection_tree
          InspectionTree.new do
            # rubocop:disable Style/SymbolProc
            add_text do |string|
              string.inspect
            end
            # rubocop:enable Style/SymbolProc
          end
        end
      end
    end
  end
end
