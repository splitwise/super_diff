require "json"
require_relative "ruby_versions"

if !SuperDiff::Test.jruby? && SuperDiff::Test.version_match?(">= 2.7.0")
  require "objspace"
end

module SuperDiff
  module Test
    if jruby?
      def self.object_id_hex(object)
        # Source: <https://github.com/jruby/jruby/blob/master/core/src/main/java/org/jruby/RubyBasicObject.java>
        "0x%x" % object.hash
      end
    elsif version_match?(">= 2.7.0")
      def self.object_id_hex(object)
        # Sources: <https://bugs.ruby-lang.org/issues/15408> and <https://bugs.ruby-lang.org/issues/15626#Object-ID>
        address = JSON.parse(ObjectSpace.dump(object))["address"]
        "0x%016x" % Integer(address, 16)
      end
    else
      def self.object_id_hex(object)
        "0x%016x" % (object.object_id * 2)
      end
    end
  end
end
