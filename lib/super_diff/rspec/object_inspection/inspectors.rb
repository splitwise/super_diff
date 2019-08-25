module SuperDiff
  module RSpec
    module ObjectInspection
      module Inspectors
        def self.define(name, &definition)
          SuperDiff::ObjectInspection::Inspectors.define(name, &definition)
        end
      end
    end
  end
end
