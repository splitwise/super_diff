# frozen_string_literal: true

require 'forwardable'

module WarningsLogger
  # Adapted from <http://myronmars.to/n/dev-blog/2011/08/making-your-gem-warning-free>
  class Spy
    def self.enable(configuration)
      new(configuration).enable
    end

    extend Forwardable

    def initialize(configuration)
      @filesystem = Filesystem.new(configuration)
      @reader = Reader.new(filesystem)
      @partitioner = Partitioner.new(
        configuration: configuration,
        reader: reader
      )
      @reporter = Reporter.new(
        configuration: configuration,
        filesystem: filesystem,
        partitioner: partitioner
      )

      @original_stderr = nil
    end

    def enable
      filesystem.prepare
      capture_warnings
      report_warnings_after_tests_run
    end

    private

    attr_reader :filesystem, :reader, :partitioner, :reporter

    def_delegators :filesystem, :warnings_file

    def_delegators(
      :partitioner,
      :relevant_warning_groups,
      :irrelevant_warning_groups
    )

    def capture_warnings
      @original_stderr = $stderr.dup
      $stderr.reopen(warnings_file.path)
    end

    def release_warnings
      $stderr.reopen(@original_stderr)
    end

    def report_warnings_after_tests_run
      spy = self

      if should_integrate_with_rspec?
        RSpec.configure do |config|
          config.after(:suite) do
            spy.instance_eval do
              release_warnings
              printing_exceptions do
                report_and_possibly_fail
              end
            end
          end
        end
      elsif should_integrate_with_minitest?
        Minitest.after_run do
          release_warnings
          printing_exceptions do
            report_and_possibly_fail
          end
        end
      else
        at_exit do
          release_warnings
          printing_exceptions do
            report_and_possibly_fail
          end
        end
      end
    end

    def printing_exceptions
      yield
    rescue StandardError => e
      warn "\n--- ERROR IN AT_EXIT --------------------------------"
      warn "#{e.class}: #{e.message}"
      warn e.backtrace.join("\n")
      warn '-----------------------------------------------------'
      raise e
    end

    def report_and_possibly_fail
      reader.read
      partitioner.partition

      if relevant_warning_groups.any?
        report_warnings_and_fail
      else
        print_warnings
      end
    end

    def report_warnings_and_fail
      reporter.report
      exit(1)
    end

    def print_warnings
      filesystem.warnings_file.rewind
      print filesystem.warnings_file.read
      filesystem.warnings_file.truncate(0)
    end

    def should_integrate_with_rspec?
      defined?(RSpec)
    end

    def should_integrate_with_minitest?
      defined?(Minitest) && Minitest.class_variable_get('@@installed_at_exit')
    end
  end
end
