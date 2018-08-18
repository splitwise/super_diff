require_relative "array"
require_relative "hash"
require_relative "string"
require_relative "object"

module SuperDiff
  module EqualityMatchers
    module Detector
      def self.call(klass)
        if EqualityMatchers.const_defined?(klass.name, false)
          EqualityMatchers.const_get(klass.name)
        else
          EqualityMatchers::Object
        end
      end
    end
  end
end
