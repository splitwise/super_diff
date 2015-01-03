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

# Copied from Thor specs
Kernel.module_eval do
  alias_method :must, :should
  alias_method :must_not, :should_not
  undef_method :should
  undef_method :should_not
end
