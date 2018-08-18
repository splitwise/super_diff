require "patience_diff"

require_relative "base"

module SuperDiff
  module OperationalSequencers
    class Array < Base
      def initialize(expected, actual)
        super(expected, actual)
        @sequence_matcher = PatienceDiff::SequenceMatcher.new
      end

      def call
        opcodes.flat_map do |code, a_start, a_end, b_start, b_end|
          if code == :delete
            (a_start..a_end).map do |index|
              Operation.new(
                name: :delete,
                collection: expected,
                index: index
              )
            end
          elsif code == :insert
            (b_start..b_end).map do |index|
              Operation.new(
                name: :insert,
                collection: actual,
                index: index
              )
            end
          else
            (b_start..b_end).map do |index|
              Operation.new(
                name: :noop,
                collection: actual,
                index: index
              )
            end
          end
        end
      end

      private

      attr_reader :sequence_matcher

      def opcodes
        sequence_matcher.diff_opcodes(expected, actual)
      end

      class Operation
        attr_reader :name, :collection, :index

        def initialize(name:, collection:, index:)
          @name = name
          @collection = collection
          @index = index
        end
      end
    end
  end
end
