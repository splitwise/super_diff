module SuperDiff
  module ObjectInspection
    module Inspectors
      def self.define(name, &definition)
        SuperDiff::ObjectInspection.inspector_registry.define(name, &definition)
      end
    end
  end
end
