module SuperDiff
  module ObjectInspection
    module Inspectors
      define :primitive do
        # rubocop:disable Style/SymbolProc
        add_text { |object| object.inspect }
        # rubocop:enable Style/SymbolProc
      end
    end
  end
end
