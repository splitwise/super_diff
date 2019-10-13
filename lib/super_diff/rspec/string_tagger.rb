module SuperDiff
  module RSpec
    class StringTagger
      extend AttrExtras.mixin

      method_object [:string!, :regex!, :colors!]

      def call
        before_first_capture +
          captures_and_surrounding_non_captures +
          after_last_capture
      end

      private

      def before_first_capture
        if captures.first.begin > 0
          [
            NonCapture.new(
              string,
              begin: 0,
              end: captures.first.begin - 1,
            ),
          ]
        else
          []
        end
      end

      def captures_and_surrounding_non_captures
        (0..captures.length - 1).reduce([]) do |segments, index|
          capture = captures[index]
          next_capture = captures[index + 1]

          segments << capture

          if next_capture && next_capture.begin > capture.end + 1
            segments << NonCapture.new(
              string,
              begin: capture.end + 1,
              end: next_capture.begin - 1,
            )
          end

          segments
        end
      end

      def after_last_capture
        if captures.last.end < string.length - 1
          [
            NonCapture.new(
              string,
              begin: captures.last.end + 1,
              end: string.length - 1,
            ),
          ]
        else
          []
        end
      end

      def captures
        @_captures ||= capture_offsets.map.with_index do |offset, index|
          Capture.new(
            string,
            begin: offset.begin,
            end: offset.end,
            color: colors.fetch(index),
          )
        end
      end

      def capture_offsets
        @_capture_offsets ||= match.captures.size.times.map do |i|
          # rubocop:disable Lint/UnderscorePrefixedVariableName
          _begin, _end = match.offset(i + 1)
          # rubocop:enable Lint/UnderscorePrefixedVariableName
          Range.new(_begin, _end - 1)
        end
      end

      def match
        @_match ||= begin
          match = regex.match(string)

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
        attr_reader :string, :begin, :end, :portion_of_message

        def initialize(string, args)
          @string = string
          @begin = args.fetch(:begin)
          @end = args.fetch(:end)
          @portion_of_message = string[@begin..@end]
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

        def initialize(string, color:, **rest)
          super(string, **rest)
          @color = color
        end

        def to_s
          SuperDiff::Helpers.style(color, portion_of_message)
        end
      end
    end
  end
end
