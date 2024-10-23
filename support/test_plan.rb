# frozen_string_literal: true

require 'pathname'
require 'optparse'

require_relative '../support/current_bundle'

class TestPlan
  PROJECT_DIRECTORY = Pathname.new('..').expand_path(__dir__)
  SUPPORT_DIR = PROJECT_DIRECTORY.join('spec/support')
  INSIDE_INTEGRATION_TEST = true

  def initialize(
    color_enabled: false,
    super_diff_configuration: {}
  )
    @color_enabled = color_enabled
    @super_diff_configuration = super_diff_configuration

    @pry_enabled = true
    @libraries = []
  end

  def after_fork
    reconnect_activerecord
  end

  def boot
    ENV['BUNDLE_GEMFILE'] ||= SuperDiff::CurrentBundle
                              .instance
                              .latest_appraisal
                              .gemfile_path
                              .to_s
    require 'bundler/setup'

    $LOAD_PATH.unshift(PROJECT_DIRECTORY.join('lib'))

    if Gem::Version.new(RUBY_VERSION) < Gem::Version.new('3.2')
      begin
        require 'pry-byebug'
      rescue LoadError
        require 'pry-nav'
      end
    end

    if SuperDiff::CurrentBundle.instance.current_appraisal.name.start_with?(
      'no_rails_'
    )
      require 'rspec'
    else
      require 'rails'
      require 'rspec'
      require 'rspec-rails'
    end

    require 'super_diff'
    SuperDiff.const_set(:IntegrationTests, Module.new) unless defined?(::SuperDiff::IntegrationTests)

    Dir
      .glob(SUPPORT_DIR.join('{models,matchers}/*.rb'))
      .each { |path| require path }

    require SUPPORT_DIR.join('integration/matchers')

    RSpec.configure { |config| config.include SuperDiff::IntegrationTests }
  end

  def boot_active_support
    require 'active_support'
    require 'active_support/core_ext/hash/indifferent_access'
  rescue LoadError => e
    # active_support may not be in the Gemfile, so that's okay
    puts "Error in TestPlan#boot_active_support: #{e.message}"
  end

  def boot_active_record
    require 'active_record'

    ActiveRecord::Base.establish_connection(
      adapter: 'sqlite3',
      database: ':memory:'
    )

    RSpec.configuration do |config|
      config.before do
        SuperDiff::Test::Models::ActiveRecord::Person.delete_all
        SuperDiff::Test::Models::ActiveRecord::ShippingAddress.delete_all
      end
    end

    Dir
      .glob(SUPPORT_DIR.join('models/active_record/*.rb'))
      .each { |path| require path }
  rescue LoadError => e
    # active_record may not be in the Gemfile, so that's okay
    puts "Error in TestPlan#boot_active_record: #{e.message}"
  end

  def boot_rails
    boot_active_support
    boot_active_record
  end

  def boot_rails_engine_with_action_controller
    boot_active_support

    require 'combustion'
    Combustion.initialize!(:action_controller)
  end

  def run_plain_test
    run_test_with_libraries('super_diff/rspec')
  end

  def run_rspec_active_support_test
    run_test_with_libraries('super_diff/rspec', 'super_diff/active_support')
  end

  def run_rspec_active_record_test
    run_test_with_libraries('super_diff/rspec', 'super_diff/active_record')
  end

  def run_rspec_rails_test
    run_test_with_libraries('super_diff/rspec-rails')
  end

  alias run_rspec_rails_engine_with_action_controller_test run_rspec_rails_test

  private

  attr_reader :libraries, :super_diff_configuration

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
    SuperDiff.configuration.merge!(
      super_diff_configuration.merge(color_enabled: color_enabled?)
    )

    ENV['DISABLE_PRY'] = 'true' unless pry_enabled?

    yield if block_given?

    libraries.each { |library| require library }
  end
end
