require_relative "differs/detector"
require_relative "differs/object"

module SuperDiff
  class Differ
    def self.call(expected:, actual:)
      new(expected: expected, actual: actual).call
    end

    def initialize(expected:, actual:)
      @expected = expected
      @actual = actual
    end

    def call
      if expected.is_a?(actual.class)
        Differs::Detector.call(expected.class).call(expected, actual)
      else
        Differs::Object.call(expected, actual)
      end
    end

    private

    attr_reader :expected, :actual
  end
end
