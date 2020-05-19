module SuperDiff
  module ObjectInspection
    module Inspectors
      class Primitive < Base
        def self.applies_to?(value)
          case value
          when true, false, nil, Symbol, Numeric, Regexp, Class
            true
          else
            false
          end
        end

        protected

        def inspection_tree
          InspectionTree.new do
            # rubocop:disable Style/SymbolProc
            add_text do |object|
              object.inspect
            end
            # rubocop:enable Style/SymbolProc
          end
        end
      end
    end
  end
end
