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
