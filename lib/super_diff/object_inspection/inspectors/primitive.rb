module SuperDiff
  module ObjectInspection
    module Inspectors
      Primitive = InspectionTree.new do
        # rubocop:disable Style/SymbolProc
        add_text do |object|
          object.inspect
        end
        # rubocop:enable Style/SymbolProc
      end
    end
  end
end
