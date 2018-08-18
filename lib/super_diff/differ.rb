require "patience_diff"
require_relative "csi"
require_relative "pretty_printers/array"

module SuperDiff
  class Differ
    BLACK = Csi::FourBitColor.new(:white)
    LIGHT_RED = Csi::TwentyFourBitColor.new(r: 73, g: 62, b: 71)
    RED = Csi::TwentyFourBitColor.new(r: 116, g: 78, b: 84)
    LIGHT_GREEN = Csi::TwentyFourBitColor.new(r: 51, g: 81, b: 81)
    GREEN = Csi::TwentyFourBitColor.new(r: 81, g: 115, b: 105)
    ICONS = { deleted: "-", inserted: "+" }
    STYLES = { inserted: :inserted, deleted: :deleted, equal: :normal }
    COLORS = { normal: :plain, inserted: :green, deleted: :red }

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

        <<~OUTPUT.strip
          Differing strings.

          #{deleted  "Expected: #{inspect(expected)}"}
          #{inserted "  Actual: #{inspect(actual)}"}

          Diff:

          #{diff}
        OUTPUT
      else
        <<~OUTPUT.strip
          Differing strings.

          #{deleted  "Expected: #{inspect(expected)}"}
          #{inserted "  Actual: #{inspect(actual)}"}
        OUTPUT
      end
    end

    def diff_arrays
      a, b = expected, actual
      opcodes = sequence_matcher.diff_opcodes(a, b)
      larger_collection =
        if actual.length > expected.length
          actual
        else
          expected
        end

      events = opcodes.flat_map do |code, a_start, a_end, b_start, b_end|
        if code == :delete
          (a_start..a_end).map do |index|
            {
              state: :deleted,
              index: index,
              collection: expected,
              larger_collection: larger_collection
            }
          end
        elsif code == :insert
          (b_start..b_end).map do |index|
            {
              state: :inserted,
              index: index,
              collection: actual,
              larger_collection: larger_collection
            }
          end
        else
          (b_start..b_end).map do |index|
            {
              state: :equal,
              index: index,
              collection: actual,
              larger_collection: larger_collection
            }
          end
        end
      end

      contents = events.map do |event|
        index = event[:index]
        collection = event[:collection]
        # larger_collection = event[:larger_collection]

        icon = ICONS.fetch(event[:state], " ")
        style_name = STYLES.fetch(event[:state], :normal)
        chunk = build_chunk(
          inspect(collection[index]),
          indent: 4,
          icon: icon
        )

        if index < collection.length - 1
          chunk << ","
        end

        style_chunk(style_name, chunk)
      end

      diff = ["  [", *contents, "  ]"].join("\n")

      <<~OUTPUT.strip
        Differing arrays.

        #{deleted  "Expected: #{expected.inspect}"}
        #{inserted "  Actual: #{actual.inspect}"}

        Diff:

        #{diff}
      OUTPUT
    end

    def diff_hashes
      all_keys = (expected.keys | actual.keys)

      events = all_keys.inject([]) do |array, key|
        if expected.include?(key)
          if actual.include?(key)
            if expected[key] == actual[key]
              array << {
                state: :equal,
                key: key,
                collection: actual
              }
            else
              array << {
                state: :deleted,
                key: key,
                collection: expected
              }
              array << {
                state: :inserted,
                key: key,
                collection: actual
              }
            end
          else
            array << {
              state: :deleted,
              key: key,
              collection: expected
            }
          end
        elsif actual.include?(key)
          array << {
            state: :inserted,
            key: key,
            collection: actual
          }
        end

        array
      end

      if events.any? { |event| event != :equal }
        contents = events.map do |event|
          key = event[:key]
          collection = event[:collection]
          index = collection.keys.index(key)
          # larger_collection = event[:larger_collection]

          icon = ICONS.fetch(event[:state], " ")
          style_name = STYLES.fetch(event[:state], :normal)
          entry =
            if key.is_a?(Symbol)
              "#{key}: #{inspect(collection[key])}"
            else
              "#{key.inspect} => #{inspect(collection[key])}"
            end

          chunk = build_chunk(
            entry,
            indent: 4,
            icon: icon
          )

          if index < collection.size - 1
            chunk << ","
          end

          style_chunk(style_name, chunk)
        end

        diff = ["  {", *contents, "  }"].join("\n")

        <<~OUTPUT.strip
          Differing hashes.

          #{deleted  "Expected: #{inspect(expected)}"}
          #{inserted "  Actual: #{inspect(actual)}"}

          Diff:

          #{diff}
        OUTPUT
      else
        ""
      end
    end

    def diff_objects
      <<~OUTPUT.strip
        Differing #{plural_type_for(actual)}.

        #{deleted  "Expected: #{expected.inspect}"}
        #{inserted "  Actual: #{actual.inspect}"}
      OUTPUT
    end

    def style_chunk(style_name, chunk)
      chunk.split("\n").map { |line| style(style_name, line) }.join("\n")
    end

    def style(style_name, text)
      Csi::ColorHelper.public_send(COLORS.fetch(style_name), text)
    end

    def normal(text)
      Csi::ColorHelper.plain(text)
    end

    def inserted(text)
      Csi::ColorHelper.green(text)
    end

    def deleted(text)
      Csi::ColorHelper.red(text)
    end

    def faded(text)
      Csi::ColorHelper.dark_grey(text)
    end

    def plural_type_for(value)
      case value
      when Numeric then "numbers"
      when String then "strings"
      when Symbol then "symbols"
      else "objects"
      end
    end

    def build_chunk(text, indent:, icon:)
      text
        .split("\n")
        .map { |line| icon + (" " * (indent - 1)) + line }
        .join("\n")
    end

    def inspect(value)
      case value
      when Hash
        value.inspect.
          gsub(/([^,]+)=>([^,]+)/, '\1 => \2').
          gsub(/:(\w+) => /, '\1: ').
          gsub(/\{([^{}]+)\}/, '{ \1 }')
      when String
        newline = "⏎"
        value.gsub(/\r\n/, newline).gsub(/\n/, newline).inspect
      else
        inspected_value = value.inspect
        match = inspected_value.match(/\A#<([^ ]+)(.*)>\Z/)

        if match
          [
            "#<#{match.captures[0]} {",
            *match.captures[1].split(" ").map { |line| "  " + line },
            "}>"
          ].join("\n")
        else
          inspected_value
        end
      end
    end
  end
end
