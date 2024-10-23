# frozen_string_literal: true

require 'fileutils'

module WarningsLogger
  class Filesystem
    def initialize(configuration)
      @configuration = configuration
      @files_by_name = Hash.new do |hash, name|
        hash[name] = file_for(name)
      end
    end

    def prepare
      temporary_directory.rmtree if temporary_directory.exist?

      temporary_directory.mkpath
    end

    def warnings_file
      files_by_name['all_warnings']
    end

    def irrelevant_warnings_file
      files_by_name['irrelevant_warnings']
    end

    def relevant_warnings_file
      files_by_name['relevant_warnings']
    end

    private

    attr_reader :configuration, :files_by_name

    def file_for(name)
      path_for(name).open('w+')
    end

    def path_for(name)
      temporary_directory.join("#{name}.txt")
    end

    def temporary_directory
      configuration.project_directory.join('tmp/warnings_logger')
    end
  end
end
