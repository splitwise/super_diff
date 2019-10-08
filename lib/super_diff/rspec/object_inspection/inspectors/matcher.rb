module SuperDiff
  module RSpec
    module ObjectInspection
      module Inspectors
        Matcher = SuperDiff::ObjectInspection::InspectionTree.new do
          # rubocop:disable Style/SymbolProc
          add_text do |object|
            object.description
          end
          # rubocop:enable Style/SymbolProc
        end
      end
    end
  end
end
