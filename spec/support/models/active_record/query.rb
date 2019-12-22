module SuperDiff
  module Test
    module Models
      module ActiveRecord
        class Query
          attr_reader :results

          def initialize(results:)
            @results = results
          end
        end
      end
    end
  end
end
