require 'rubygems'

gem 'minitest'
require 'minitest/autorun'
require 'stringio'

require 'differ'

require File.expand_path("../../lib/super_diff", __FILE__)

module SuperDiff
  class TestCase < MiniTest::Unit::TestCase
    module Matchers
      # Override assert_equal to use Differ
      def assert_equal(expected, actual, message=nil)
        if String === expected && String === actual
          difference = Differ.diff_by_char(expected, actual)
          extra = "\n\nDifference:\n\n#{difference}"
        end
        full_message = message(message) { "Expected: <#{expected.inspect}>\n          Got: <#{actual.inspect}>#{extra}" }
        assert(expected == actual, full_message)
      end

      def assert_empty(value, message="Expected value to be empty, but wasn't.")
        assert value.empty?, message
      end
    end
    
    include Matchers
  end
end

class << MiniTest::Spec
  alias_method :test, :it
end

Dir[File.expand_path("../support/**/*.rb", __FILE__)].each {|f| require f }