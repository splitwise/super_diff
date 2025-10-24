# frozen_string_literal: true

module SuperDiff
  module IntegrationTests
    module TestPrograms
      class RSpecActionDispatch < Base
        protected

        def test_plan_prelude
          <<~PRELUDE.strip
            test_plan.boot
            test_plan.boot_action_dispatch
          PRELUDE
        end

        def test_plan_command
          'run_rspec_action_dispatch_test'
        end
      end
    end
  end
end
