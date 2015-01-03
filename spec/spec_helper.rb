require 'stringio'

require 'rspec/core'
require 'rspec/expectations'

require 'super_diff'

RSpec.configure do |c|
  c.mock_framework = :nothing
  c.backtrace_clean_patterns = [
    /bin\//,
    /gems/,
    /spec\/spec_helper\.rb/,
    /lib\/rspec\/(core|expectations|matchers|mocks)/
  ]
end

module RSpec
  module Matchers
    class PositiveOperatorMatcher < OperatorMatcher #:nodoc:
      def __delegate_operator(actual, operator, expected)
        if actual.__send__(operator, expected)
          true
        #elsif Hash === expected && Hash === actual || Array === expected && Array === actual
        #  data = SuperDiff::Differ.new.diff(expected, actual)
        #  #SuperDiff::Reporter.new($stdout).report(data)
        #  fail_with_message("Inequal data structures.\n\n#{data.pretty_inspect}")
        elsif ['==','===', '=~'].include?(operator)
          fail_with_message("expected:\n#{expected.pretty_inspect}\n     got:\n#{actual.pretty_inspect} (using #{operator})")
        else
          fail_with_message("expected: #{operator} #{expected.inspect}\n     got: #{operator.gsub(/./, ' ')} #{actual.inspect}")
        end
      end

    end
  end
end
