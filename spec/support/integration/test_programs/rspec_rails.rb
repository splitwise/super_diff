module SuperDiff
  module IntegrationTests
    module TestPrograms
      class RspecRails < Base
        protected

        def test_plan_prelude
          "test_plan.boot_active_record"
        end

        def test_plan_command
          "run_rspec_rails_test"
        end
      end
    end
  end
end
