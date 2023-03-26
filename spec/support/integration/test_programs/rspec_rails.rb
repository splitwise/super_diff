module SuperDiff
  module IntegrationTests
    module TestPrograms
      class RSpecRails < Base
        protected

        def test_plan_prelude
          <<~PRELUDE.strip
            test_plan.boot
            test_plan.boot_active_record
          PRELUDE
        end

        def test_plan_command
          "run_rspec_rails_test"
        end
      end
    end
  end
end
