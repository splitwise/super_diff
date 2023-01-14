require "pathname"
require "optparse"

require_relative "../support/current_bundle"

class TestPlan
  PROJECT_DIRECTORY = Pathname.new("..").expand_path(__dir__)
  SUPPORT_DIR = PROJECT_DIRECTORY.join("spec/support")
  INSIDE_INTEGRATION_TEST = true

  def initialize(
    using_outside_of_zeus: false,
    color_enabled: false,
    configuration: {}
  )
    @using_outside_of_zeus = using_outside_of_zeus
    @color_enabled = color_enabled
    @configuration = configuration

    @pry_enabled = true
    @libraries = []
  end

  def after_fork
    reconnect_activerecord
  end

  def boot
    ENV["BUNDLE_GEMFILE"] ||=
      SuperDiff::CurrentBundle.instance.latest_appraisal.gemfile_path.to_s
    require "bundler/setup"

    $LOAD_PATH.unshift(PROJECT_DIRECTORY.join("lib"))

    begin
      require "pry-byebug"
    rescue LoadError
      require "pry-nav"
    end

    # Fix Zeus for 0.13.0+
    Pry::Pager.class_eval do
      def best_available
        Pry::Pager::NullPager.new(pry_instance.output)
      end
    end

    if SuperDiff::CurrentBundle.instance.current_appraisal.name.start_with?("no_rails_")
      require "rspec"
    else
      require "rails"
      require "rspec"
      require "rspec-rails"
    end

    require "super_diff"
    SuperDiff.const_set(:IntegrationTests, Module.new)

    Dir.glob(SUPPORT_DIR.join("{models,matchers}/*.rb")).sort.each do |path|
      require path
    end

    require SUPPORT_DIR.join("integration/matchers")

    RSpec.configure do |config|
      config.include SuperDiff::IntegrationTests
    end
  end

  def boot_active_support
    require "active_support"
    require "active_support/core_ext/hash/indifferent_access"
  rescue LoadError
    # active_support may not be in the Gemfile, so that's okay
    puts "Error in TestPlan#boot_active_support: #{e.message}"
  end

  def boot_active_record
    require "active_record"

    ActiveRecord::Base.establish_connection(
      adapter: "sqlite3",
      database: ":memory:",
    )

    RSpec.configuration do |config|
      config.before do
        SuperDiff::Test::Models::ActiveRecord::Person.delete_all
        SuperDiff::Test::Models::ActiveRecord::ShippingAddress.delete_all
      end
    end

    Dir.glob(SUPPORT_DIR.join("models/active_record/*.rb")).sort.each do |path|
      require path
    end
  rescue LoadError => e
    # active_record may not be in the Gemfile, so that's okay
    puts "Error in TestPlan#boot_active_record: #{e.message}"
  end

  def boot_rails
    boot_active_support
    boot_active_record
  end

  def run_plain_test
    run_test_with_libraries("super_diff/rspec")
  end

  def run_rspec_active_support_test
    run_test_with_libraries("super_diff/rspec", "super_diff/active_support")
  end

  def run_rspec_active_record_test
    run_test_with_libraries("super_diff/rspec", "super_diff/active_record")
  end

  def run_rspec_rails_test
    run_test_with_libraries("super_diff/rspec-rails")
  end

  private

  attr_reader :libraries, :configuration

  def using_outside_of_zeus?
    @using_outside_of_zeus
  end

  def color_enabled?
    @color_enabled
  end

  def pry_enabled?
    @pry_enabled
  end

  def reconnect_activerecord
    return unless defined?(ActiveRecord::Base)

    begin
      ActiveRecord::Base.clear_all_connections!
      ActiveRecord::Base.establish_connection
      if ActiveRecord::Base.respond_to?(:shared_connection)
        ActiveRecord::Base.shared_connection =
          ActiveRecord::Base.retrieve_connection
      end
    rescue ActiveRecord::AdapterNotSpecified
    end
  end

  def run_test_with_libraries(*libraries)
    if !using_outside_of_zeus?
      option_parser.parse!
    end

    SuperDiff.configuration.merge!(
      configuration.merge(color_enabled: color_enabled?)
    )

    if !pry_enabled?
      ENV["DISABLE_PRY"] = "true"
    end

    yield if block_given?

    libraries.each { |library| require library }

    if !using_outside_of_zeus?
      RSpec::Core::Runner.invoke
    end
  end

  def option_parser
    @_option_parser ||= OptionParser.new do |opts|
      opts.on("--[no-]color", "Enable or disable color.") do |value|
        @color_enabled = value
      end

      opts.on("--[no-]pry", "Disable Pry.") do |value|
        @pry_enabled = value
      end

      opts.on("--configuration CONFIG", String, "Configure SuperDiff.") do |json|
        @configuration = JSON.parse(json).transform_keys(&:to_sym)
      end
    end
  end
end
