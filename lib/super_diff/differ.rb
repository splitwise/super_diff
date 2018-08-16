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
          diff_strings
        elsif expected.is_a?(Array) && actual.is_a?(Array)
          diff_arrays
        elsif expected.is_a?(Hash) && actual.is_a?(Hash)
          diff_hashes
        else
          diff_objects
        end
      end
    end

    private

    attr_reader :expected, :actual, :color, :sequence_matcher

    def diff_strings
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

        <<~OUTPUT
          Differing strings.

          Expected: #{expected.inspect}
            Actual: #{actual.inspect}

          Diff:

          #{diff}
        OUTPUT
      else
        <<~OUTPUT
          Differing strings.

          Expected: #{expected.inspect}
            Actual: #{actual.inspect}
        OUTPUT
      end
    end

    def diff_arrays
      a, b = expected, actual
      opcodes = sequence_matcher.diff_opcodes(a, b)

      normalized_opcodes = opcodes.flat_map do |code, a_start, a_end, b_start, b_end|
        if code == :delete
          { state: :deleted, index_range: (a_start..a_end), collection: expected }
        elsif code == :insert
          { state: :inserted, index_range: (b_start..b_end), collection: actual }
        else
          { state: :equal, index_range: (b_start..b_end), collection: actual }
        end
      end

      i = 0
      details = []
      while i < normalized_opcodes.length
        first_event = normalized_opcodes[i]
        second_event = normalized_opcodes[i + 1]
        if (
            first_event[:state] == :deleted &&
            first_event[:index_range].size == 1 &&
            second_event &&
            second_event[:state] == :inserted &&
            second_event[:index_range].size == 1
        )
          index = first_event[:index_range].first
          details << "- *[#{index}]: Differing #{plural_type_for(actual[index])}.\n" +
            "  Expected: #{expected[index].inspect}\n" +
            "    Actual: #{actual[index].inspect}"
          i += 2
        else
          if first_event[:state] == :inserted
            first_event[:index_range].each do |index|
              details << "- *[? -> #{index}]: " +
                "Actual has extra element #{actual[index].inspect}."
            end
          elsif first_event[:state] == :deleted
            first_event[:index_range].each do |index|
              details << "- *[#{index} -> ?]: " +
                "Actual is missing element #{expected[index].inspect}."
            end
          end
          i += 1
        end
      end

      <<~OUTPUT
        Differing arrays.

        Expected: #{expected.inspect}
          Actual: #{actual.inspect}

        Details:

        #{details.join("\n")}
      OUTPUT
    end

    def diff_hashes
      all_keys = (expected.keys | actual.keys)

      details = all_keys.inject([]) do |array, key|
        if expected.include?(key)
          if actual.include?(key)
            if expected[key] == actual[key]
              array
            else
              array << "*[#{key.inspect}]: " +
                "Differing #{plural_type_for(actual[key])}.\n" +
                "  Expected: #{expected[key].inspect}\n" +
                "    Actual: #{actual[key].inspect}"
            end
          else
            array << "*[#{key.inspect} -> ?]: Actual is missing key."
          end
        else
          if actual.include?(key)
            array << "*[? -> #{key.inspect}]: " +
              "Actual has extra key (with value of #{actual[key].inspect})."
          else
            array
          end
        end
      end

      if details.any?
        <<~OUTPUT
          Differing hashes.

          Expected: #{inspect(expected)}
            Actual: #{inspect(actual)}

          Details:

          #{details.map { |detail| "- #{detail}"}.join("\n")}
        OUTPUT
      else
        ""
      end
    end

    def diff_objects
      <<~OUTPUT
        Differing #{plural_type_for(actual)}.

        Expected: #{expected.inspect}
          Actual: #{actual.inspect}
      OUTPUT
    end

    def normal(text)
      Csi::ColorHelper.plain(text)
    end

    def inserted(text)
      Csi::ColorHelper.light_green_bg(text)
    end

    def deleted(text)
      Csi::ColorHelper.light_red_bg(text)
    end

    def plural_type_for(value)
      case value
      when Numeric then "numbers"
      when String then "strings"
      when Symbol then "symbols"
      else "objects"
      end
    end

    def inspect(value)
      if value.is_a?(Hash)
        value.inspect.
          gsub(/([^,]+)=>([^,]+)/, '\1 => \2').
          gsub(/:(\w+) => /, '\1: ').
          gsub(/\{([^{}]+)\}/, '{ \1 }')
      else
        value.inspect
      end
    end
  end
end
