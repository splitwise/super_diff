module SuperDiff
  module RSpec
    module ExceptionMessageFormatters
      class Base
        extend AttrExtras.mixin

        def self.applies_to?(message)
          # puts regex
          # puts message
          regex.match?(message.to_s)
        end

        def self.regex
          raise NotImplementedError.new(
            "Please implement .regex in your subclass",
          )
        end

        attr_private :message

        def self.call(message)
          new(message).call
        end

        def initialize(message)
          @message = message.to_s
        end

        def call
          ranges.map(&:to_s).join
        end

        protected

        def ranges
          @_ranges ||= determine_ranges
        end

        def determine_ranges
          ranges = []

          if captures.first.begin > 0
            ranges << NonCapture.new(
              message,
              begin: 0,
              end: captures.first.begin - 1,
            )
          end

          0.upto(captures.length - 1) do |index|
            ranges << captures[index]

            if (
              index < captures.length - 1 &&
              captures[index + 1].begin > captures[index].end + 1
            )
              ranges << NonCapture.new(
                message,
                begin: captures[index].end + 1,
                end: captures[index + 1].begin - 1,
              )
            end
          end

          if captures.last.end < message.length - 1
            ranges << NonCapture.new(
              message,
              begin: captures.last.end + 1,
              end: message.length - 1,
            )
          end

          ranges
        end

        def captures
          @_captures ||= capture_offsets.map.with_index do |offset, index|
            Capture.new(
              message,
              begin: offset.begin,
              end: offset.end,
              color: colors.fetch(index),
            )
          end
        end

        def capture_offsets
          @_capture_offsets ||= match.captures.size.times.map do |i|
            _begin, _end = match.offset(i + 1)
            Range.new(_begin, _end - 1)
          end
        end

        def match
          @_match ||= begin
            match = self.class.regex.match(message)

            if !match
              raise "Regex doesn't match!"
            end

            if match.captures.empty?
              raise "There are no captures!"
            end

            match
          end
        end

        class Segment
          extend AttrExtras.mixin

          attr_reader :message, :begin, :end, :portion_of_message

          def initialize(message, args)
            @message = message
            @begin = args.fetch(:begin)
            @end = args.fetch(:end)
            @portion_of_message = message[@begin..@end]
          end

          def to_s
            raise NotImplementedError
          end
        end

        class NonCapture < Segment
          def to_s
            portion_of_message
          end
        end

        class Capture < Segment
          attr_reader :color

          def initialize(message, color:, **rest)
            super(message, **rest)
            @color = color
          end

          def to_s
            SuperDiff::Helpers.style(color, portion_of_message)
          end
        end
      end
    end
  end
end
