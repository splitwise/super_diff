require_relative "../super_diff"
require_relative "rspec/differ"
require_relative "rspec/monkey_patches"

module SuperDiff
  module RSpec
    class << self
      attr_accessor :extra_operational_sequencer_classes
      attr_accessor :extra_diff_formatter_classes

      def configure
        yield self
      end
    end

    self.extra_operational_sequencer_classes = []
    self.extra_diff_formatter_classes = []
  end
end
