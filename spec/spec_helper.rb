require_relative "../lib/super_diff"
require_relative "../lib/super_diff/rspec"

begin
  require "pry-byebug"
rescue LoadError
end

begin
  require "pry-nav"
rescue LoadError
end

Dir.glob(File.expand_path("../support/**/*.rb", __FILE__)).each do |file|
  require file
end

RSpec.configure do |config|
  config.include(SuperDiff::IntegrationTests, type: :integration)

  config.expect_with :rspec do |expectations|
    expectations.include_chain_clauses_in_custom_matcher_descriptions = true
    expectations.max_formatted_output_length = nil
  end

  config.mock_with :rspec do |mocks|
    mocks.verify_partial_doubles = true
  end

  config.shared_context_metadata_behavior = :apply_to_host_groups
  config.filter_run_when_matching :focus
  config.example_status_persistence_file_path = "spec/examples.txt"
  config.disable_monkey_patching!
  config.warnings = true

  if config.files_to_run.one?
    config.default_formatter = "documentation"
  end

  config.order = :random
  Kernel.srand config.seed
end

require "pp"
