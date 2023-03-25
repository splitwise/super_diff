module SuperDiff
  module IntegrationTests
    module TestPrograms
      class RspecRailsEngine < Base
        def initialize(*args, combustion_initialize:, **options)
          super(*args, **options)
          @combustion_initialize = combustion_initialize
        end

        protected

        def test_plan_prelude
          <<~PRELUDE.strip
            test_plan.boot_rails_engine(
              combustion_initialize: #{combustion_initialize.inspect}
            )
          PRELUDE
        end

        def test_plan_command
          "run_rspec_rails_test"
        end

        private

        attr_reader :combustion_initialize
      end
    end
  end
end
