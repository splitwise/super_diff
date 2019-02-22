# WIPPPPPPPPPPPPPPPPPPPPPp
=begin
module SuperDiff
  module RSpec
    class AliasedMatcherInspector
      def self.applies?(value)
        value.is_a?(RSpec::Matchers::AliasedMatcher)
      end

      def initialize(value, single_line:)
        @value = value
        @single_line = single_line
      end

      def call
        case value.base_matcher
        when RSpec::Matchers::BuiltIn::Include
          if single_line
            "(#{value.description})"
          else
            described_matcher_type = value.matcher_type.gsub("_", " ")

            if value.base_matcher.instance_variable_get("@actual").is_a?(Hash)
              ValueInspection.new(
                beginning: "(#{described_matcher_type} {",
                middle: contents.map.with_index do |line, index|
                  # if index < contents.size - 1
                  # line + ","
                  # else
                  line
                  # end
                end,
                end: "})",
              )
            else
              raise "Don't know how to inspect this AliasedMatcher"
            end
          end
        else
          value.inspect
        end
      end

      private

      def inspect_hash(hash)
        contents = hash.map do |key, value|
          inspected_value = inspect_object(value, single_line: single_line)

          if key.is_a?(Symbol)
            "#{key}: #{inspected_value}"
          elsif inspected_value.is_a?(ValueInspection)
            ["#{inspect_object(key)} => ", inspected_value]
          else
            "#{inspect_object(key)} => #{inspected_value}"
          end
        end

        if single_line
          ["{", contents.join(", "), "}"].join(" ")
        else
          ValueInspection.new(
            beginning: "{",
            middle: contents.map.with_index do |line, index|
              # if index < contents.size - 1
                # line + ","
              # else
                line
              # end
            end,
            end: "}",
          )
        end
      end
    end
  end
end

SuperDiff.configure do |config|
  config.inspectors << SuperDiff::RSpec::AliasedMatcherInspector
end
=end
