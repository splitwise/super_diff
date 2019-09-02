module SuperDiff
  module ObjectInspection
    module Inspectors
      define :string do
        add_text do |string|
          string.inspect
        end
      end
    end
  end
end
