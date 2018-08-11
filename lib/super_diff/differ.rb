require "patience_diff"
require_relative "./csi"

module SuperDiff
  class Differ
    BLACK = Csi::FourBitColor.new(:white)
    LIGHT_RED = Csi::TwentyFourBitColor.new(r: 73, g: 62, b: 71)
    RED = Csi::TwentyFourBitColor.new(r: 116, g: 78, b: 84)
    LIGHT_GREEN = Csi::TwentyFourBitColor.new(r: 51, g: 81, b: 81)
    GREEN = Csi::TwentyFourBitColor.new(r: 81, g: 115, b: 105)

    def self.call(expected:, actual:)
      new(expected: expected, actual: actual).call
    end

    def initialize(expected:, actual:)
      @expected = expected
      @actual = actual
      @sequence_matcher = PatienceDiff::SequenceMatcher.new
    end

    def call
      if expected == actual
        ""
      else
        if expected.is_a?(String) && actual.is_a?(String)
          if expected.include?("\n") || actual.include?("\n")
            a = expected.split(/\n/).map { |line| "#{line}⏎" }
            b = actual.split(/\n/).map { |line| "#{line}⏎" }
            opcodes = sequence_matcher.diff_opcodes(a, b)

            diff = opcodes.flat_map do |code, a_start, a_end, b_start, b_end|
              if code == :equal
                b[b_start..b_end].map { |line| normal(" #{line}") }
              elsif code == :insert
                b[b_start..b_end].map { |line| inserted("+ #{line}") }
              else
                a[a_start..a_end].map { |line| deleted("- #{line}") }
              end
            end.join("\n")

            if expected != actual
              <<~OUTPUT
                Differing strings.

                Expected: #{expected.inspect}
                     Got: #{actual.inspect}

                Diff:

                #{diff}
              OUTPUT
            else
              ""
            end
          else
            <<~OUTPUT
              Differing strings.

              Expected: #{expected.inspect}
                   Got: #{actual.inspect}

              Diff:

              #{deleted("- #{expected}")}
              #{inserted("+ #{actual}")}
            OUTPUT
          end
        else
          <<~OUTPUT
            Differing objects.

            Expected: #{expected.inspect}
                 Got: #{actual.inspect}
          OUTPUT
        end
      end
    end

    private

    attr_reader :expected, :actual, :color, :sequence_matcher

    def normal(text)
      Csi::ColorHelper.plain(text)
    end

    def inserted(text)
      Csi::ColorHelper.light_green_bg(text)
    end

    def deleted(text)
      Csi::ColorHelper.light_red_bg(text)
    end
  end
end
