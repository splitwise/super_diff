def rubygems_require(path)
  require path
rescue LoadError => e
  require 'rubygems'
  require path
end

require 'test/unit'
require 'stringio'

rubygems_require 'turn'
rubygems_require 'differ'

require File.expand_path("../../lib/super_diff", __FILE__)

module SuperDiff
  class TestCase < Test::Unit::TestCase
    module Matchers
      # Override assert_equal to use Differ
      def assert_equal(expected, actual, message=nil)
        if String === expected && String === actual
          difference = Differ.diff_by_char(expected, actual)
          extra = "\n\nDifference:\n\n#{difference}"
        end
        full_message = build_message(message, "Expected: <#{expected.inspect}>\nGot: <#{actual.inspect}>#{extra}")
        assert_block(full_message) { expected == actual }
      end

      def assert_empty(value, message="Expected value to be empty, but wasn't.")
        assert value.empty?, message
      end
    end
    
    include Matchers
  end
end