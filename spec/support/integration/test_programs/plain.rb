# frozen_string_literal: true

module SuperDiff
  module IntegrationTests
    module TestPrograms
      class Plain < Base
        protected

        def test_plan_prelude
          <<~PRELUDE.strip
            test_plan.boot
          PRELUDE
        end

        def test_plan_command
          'run_plain_test'
        end
      end
    end
  end
end
