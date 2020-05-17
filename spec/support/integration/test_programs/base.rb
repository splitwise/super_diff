module SuperDiff
  module IntegrationTests
    module TestPrograms
      class Base
        extend AttrExtras.mixin

        PROJECT_DIRECTORY = Pathname.new("../../../..").expand_path(__dir__)
        TEMP_DIRECTORY = PROJECT_DIRECTORY.join("tmp")

        attr_private :code, :color_enabled, :preserve_as_whole_file

        def initialize(code, color_enabled:, preserve_as_whole_file: false)
          @code = code.strip
          @color_enabled = color_enabled
          @preserve_as_whole_file = preserve_as_whole_file
        end

        def run
          result_of_command
        end

        protected

        def test_plan_prelude
          ""
        end

        def test_plan_command
          raise NotImplementedError
        end

        private

        attr_query :color_enabled?
        attr_query :preserve_as_whole_file?

        def result_of_command
          @_result_of_command ||=
            if zeus_running?
              Bundler.with_unbundled_env { CommandRunner.run(*command) }
            else
              CommandRunner.run(*command)
            end
        end

        def command
          if ENV["RAILS_ENV"]
            raise "RAILS_ENV is being set somehow?!"
          end

          if zeus_running?
            ["zeus", test_plan_command, color_option, tempfile.to_s]
          else
            [
              "rspec",
              "--options",
              "/tmp/dummy-rspec-config",
              tempfile.to_s,
            ]
          end
        end

        def zeus_running?
          PROJECT_DIRECTORY.join(".zeus.sock").exist?
        end

        def color_option
          color_enabled ? "--color" : "--no-color"
        end

        def tempfile
          @_tempfile ||= begin
            TEMP_DIRECTORY.mkpath
            TEMP_DIRECTORY.join("integration_spec.rb").tap do |file|
              file.write(program)
            end
          end
        end

        def program
          if zeus_running?
            minimal_program
          else
            <<~PROGRAM
              require "#{PROJECT_DIRECTORY.join("support/test_plan.rb")}"

              test_plan = TestPlan.new(
                using_outside_of_zeus: true,
                color_enabled: #{color_enabled?}
              )
              test_plan.boot
              #{test_plan_prelude}
              test_plan.#{test_plan_command}

              #{minimal_program}
            PROGRAM
          end
        end

        def minimal_program
          if preserve_as_whole_file?
            code
          else
            <<~PROGRAM
              RSpec.describe "test" do
                it "passes" do
                  #{reindent(code, level: 2)}
                end
              end
            PROGRAM
          end
        end

        def reindent(code, level: 0)
          code.strip.split("\n").map { |line| ("  " * level) + line }.join("\n")
        end
      end
    end
  end
end
