module SuperDiff
  module IntegrationTests
    module TestPrograms
      class RspecActiveRecord < Base
        protected

        def test_plan_prelude
          "test_plan.boot_active_record"
        end

        def test_plan_command
          "run_rspec_active_record_test"
        end
      end
    end
  end
end
