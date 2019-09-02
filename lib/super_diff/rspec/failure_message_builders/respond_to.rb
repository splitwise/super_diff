module SuperDiff
  module RSpec
    module FailureMessageBuilders
      class RespondTo < Base
        def initialize(extra:, **rest)
          super(rest)
          @extra = extra
        end

        protected

        def add_expected_value_to(template)
          template.add_list_in_color(expected_color, expected)
        end

        def add_extra
          template.add_text extra
        end

        private

        attr_reader :extra
      end
    end
  end
end
