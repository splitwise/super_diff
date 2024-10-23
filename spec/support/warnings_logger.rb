# frozen_string_literal: true

require_relative 'warnings_logger/configuration'
require_relative 'warnings_logger/filesystem'
require_relative 'warnings_logger/partitioner'
require_relative 'warnings_logger/reader'
require_relative 'warnings_logger/reporter'
require_relative 'warnings_logger/spy'

module WarningsLogger
  class << self
    attr_writer :configuration

    def configure(&block)
      configuration.update!(&block)
    end

    def configuration
      @configuration ||= Configuration.new
    end

    def enable
      WarningsLogger::Spy.enable(configuration)
    end
  end
end
