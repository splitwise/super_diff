# frozen_string_literal: true

require 'forwardable'

module WarningsLogger
  class Reporter
    extend Forwardable

    def initialize(configuration:, filesystem:, partitioner:)
      @configuration = configuration
      @filesystem = filesystem
      @partitioner = partitioner
    end

    def report
      reporting_all_groups do
        report_relevant_warning_groups
        report_irrelevant_warning_groups
      end
    end

    private

    attr_reader :configuration, :filesystem, :partitioner

    def_delegators :configuration, :project_name

    def_delegators(
      :filesystem,
      :warnings_file,
      :relevant_warnings_file,
      :irrelevant_warnings_file
    )

    def_delegators(
      :partitioner,
      :relevant_warning_groups,
      :irrelevant_warning_groups
    )

    def reporting_all_groups
      return unless relevant_warning_groups.any? || irrelevant_warning_groups.any?

      warn ''
      yield
      warn "All warnings were written to #{warnings_file.path}."
      warn ''
    end

    def report_relevant_warning_groups
      return unless relevant_warning_groups.any?

      print_divider('-', 75, header: " #{project_name} warnings: ")
      relevant_warning_groups.each do |group|
        group.each do |line|
          relevant_warnings_file.puts(line)
          warn line
        end
      end
      print_divider('-', 75)
      warn(
        "#{project_name} warnings written to #{relevant_warnings_file.path}."
      )
    end

    def report_irrelevant_warning_groups
      return unless irrelevant_warning_groups.any?

      irrelevant_warning_groups.each do |group|
        group.each do |line|
          irrelevant_warnings_file.puts(line)
        end
      end
      warn(
        "Non #{project_name} warnings were raised during the test run. " \
        "These have been written to #{irrelevant_warnings_file.path}."
      )
    end

    def print_divider(character, count, options = {})
      warn

      if options[:header]
        first_count = 10
        second_count = count - options[:header].length - first_count
        string =
          horizontal_rule(character, first_count) +
          options[:header] +
          horizontal_rule(character, second_count)
        warn string
      else
        warn horizontal_rule(character, count)
      end

      warn
    end

    def horizontal_rule(character, count)
      character * count
    end
  end
end
