# frozen_string_literal: true

require 'forwardable'

module WarningsLogger
  class Reader
    extend Forwardable

    attr_reader :warning_groups

    def initialize(filesystem)
      @filesystem = filesystem
      @current_group = []
      @warning_groups = []
    end

    def read
      warnings_file.rewind

      warnings_file.each_line do |line|
        process_line(line)
      end

      add_group(current_group)
    end

    private

    attr_reader :filesystem, :current_group

    def_delegators :filesystem, :warnings_file

    def process_line(line)
      if start_of_group?(line)
        add_group(current_group)
        @current_group = []
      end

      current_group << line
    end

    def start_of_group?(line)
      line =~ /^\S/
    end

    def add_group(group)
      return if group.empty? || group_already_added?(group)

      warning_groups << group
    end

    def group_already_added?(group_to_be_added)
      warning_groups.any? do |group|
        group == group_to_be_added
      end
    end
  end
end
