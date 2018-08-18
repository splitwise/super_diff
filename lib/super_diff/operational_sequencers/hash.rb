require_relative "base"

module SuperDiff
  module OperationalSequencers
    class Hash < Base
      def call
        all_keys.inject([]) do |sequence, key|
          if expected.include?(key)
            if actual.include?(key)
              if expected[key] == actual[key]
                sequence << Operation.new(
                  name: :noop,
                  collection: actual,
                  key: key,
                  index: actual.keys.index(key)
                )
              else
                sequence << Operation.new(
                  name: :delete,
                  collection: expected,
                  key: key,
                  index: expected.keys.index(key)
                )
                sequence << Operation.new(
                  name: :insert,
                  collection: actual,
                  key: key,
                  index: actual.keys.index(key)
                )
              end
            else
              sequence << Operation.new(
                name: :delete,
                collection: expected,
                key: key,
                index: expected.keys.index(key)
              )
            end
          elsif actual.include?(key)
            sequence << Operation.new(
              name: :insert,
              collection: actual,
              key: key,
              index: actual.keys.index(key)
            )
          end

          sequence
        end
      end

      private

      def all_keys
        (expected.keys | actual.keys)
      end

      class Operation
        attr_reader :name, :collection, :key, :index

        def initialize(name:, collection:, key:, index:)
          @name = name
          @collection = collection
          @key = key
          @index = index
        end
      end
    end
  end
end
