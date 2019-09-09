module SuperDiff
  module ObjectInspection
    module Inspectors
      String = InspectionTree.new do
        # rubocop:disable Style/SymbolProc
        add_text do |string|
          string.inspect
        end
        # rubocop:enable Style/SymbolProc
      end
    end
  end
end
