module SuperDiff
  module ObjectInspection
    module Inspectors
      define :primitive do
        add_text do |object|
          object.inspect
        end
      end
    end
  end
end
