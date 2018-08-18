require_relative "array"
require_relative "hash"
require_relative "string"
require_relative "object"

module SuperDiff
  module Differs
    module Detector
      def self.call(klass)
        if Differs.const_defined?(klass.name, false)
          Differs.const_get(klass.name)
        else
          Differs::Object
        end
      end
    end
  end
end
