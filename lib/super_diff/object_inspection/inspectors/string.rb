module SuperDiff
  module ObjectInspection
    module Inspectors
      NEWLINE = "⏎".freeze

      define :string do
        add_text do |string|
          string.gsub(/\r\n/, NEWLINE).gsub(/\n/, NEWLINE).inspect
        end
      end
    end
  end
end
