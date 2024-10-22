# frozen_string_literal: true

module SuperDiff
  module IntegrationTests
    module TestPrograms
      class RspecRailsEngineWithActionController < Base
        protected

        def test_plan_prelude
          <<~PRELUDE.strip
            test_plan.boot
            test_plan.boot_rails_engine_with_action_controller
          PRELUDE
        end

        def test_plan_command
          'run_rspec_rails_test'
        end
      end
    end
  end
end
