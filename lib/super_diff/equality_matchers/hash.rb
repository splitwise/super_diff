require_relative "collection"

module SuperDiff
  module EqualityMatchers
    class Hash < Collection
      def fail
        <<~OUTPUT.strip
          Differing hashes.

          #{style :deleted,  "Expected: #{inspect(expected)}"}
          #{style :inserted, "  Actual: #{inspect(actual)}"}

          Diff:

          #{diff}
        OUTPUT
      end

      protected

      def events
        all_keys.inject([]) do |array, key|
          if expected.include?(key)
            if actual.include?(key)
              if expected[key] == actual[key]
                array << {
                  state: :equal,
                  key: key,
                  index: actual.keys.index(key),
                  collection: actual
                }
              else
                array << {
                  state: :deleted,
                  key: key,
                  index: expected.keys.index(key),
                  collection: expected
                }
                array << {
                  state: :inserted,
                  key: key,
                  index: actual.keys.index(key),
                  collection: actual
                }
              end
            else
              array << {
                state: :deleted,
                key: key,
                index: expected.keys.index(key),
                collection: expected
              }
            end
          elsif actual.include?(key)
            array << {
              state: :inserted,
              key: key,
              index: actual.keys.index(key),
              collection: actual
            }
          end

          array
        end
      end

      private

      def all_keys
        (expected.keys | actual.keys)
      end

      def diff
        build_diff("{", "}") do |event|
          key = event[:key]
          inspected_value = inspect(event[:collection][event[:key]])

          if key.is_a?(Symbol)
            "#{key}: #{inspected_value}"
          else
            "#{key.inspect} => #{inspected_value}"
          end
        end

      end
    end
  end
end
