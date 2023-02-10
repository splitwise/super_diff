require "pp"

if Gem::Version.new(RUBY_VERSION) < Gem::Version.new("3.2")
  begin
    require "pry-byebug"
  rescue LoadError
  end

  begin
    require "pry-nav"
  rescue LoadError
  end
end

require "climate_control"

#---

require_relative "../support/current_bundle"

SuperDiff::CurrentBundle.instance.assert_appraisal!

#---

begin
  require "active_record"

  active_record_available = true

  ActiveRecord::Base.establish_connection(
    adapter: "sqlite3",
    database: ":memory:"
  )
rescue LoadError
  active_record_available = false
end

Dir
  .glob(File.expand_path("support/**/*.rb", __dir__))
  .sort
  .reject do |file|
    file.include?("/models/active_record/") && !active_record_available
  end
  .each { |file| require file }

RSpec.configure do |config|
  config.include(SuperDiff::UnitTests, type: :unit)
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

  config.default_formatter = "documentation" if !%w[true 1].include?(ENV["CI"])

  config.filter_run_excluding active_record: true unless active_record_available

  config.order = :random
  Kernel.srand config.seed

  config.color_mode = :on if ENV["CI"] == "true"
end

require "warnings_logger"
$VERBOSE = true
WarningsLogger.configure do |config|
  config.project_name = "super_diff"
  config.project_directory = Pathname.new("..").expand_path(__dir__)
end
WarningsLogger.enable

if active_record_available
  require "super_diff/rspec-rails"
else
  require "super_diff/rspec"
end
