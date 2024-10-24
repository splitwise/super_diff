# frozen_string_literal: true

require 'forwardable'

module WarningsLogger
  class Partitioner
    extend Forwardable

    attr_reader :relevant_warning_groups, :irrelevant_warning_groups

    def initialize(configuration:, reader:)
      @configuration = configuration
      @reader = reader
    end

    def partition
      @relevant_warning_groups, @irrelevant_warning_groups =
        warning_groups.partition { |group| relevant_warnings?(group) }
    end

    private

    attr_reader :configuration, :reader

    def_delegators :configuration, :project_directory
    def_delegators :reader, :warning_groups

    def relevant_warnings?(lines_in_group)
      lines_in_group[0].start_with?("#{project_directory}/lib")
    end
  end
end
