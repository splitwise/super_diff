# frozen_string_literal: true

require 'attr_extras/explicit'
require 'json'

module SuperDiff
  module IntegrationTests
    module TestPrograms
      class Base
        extend AttrExtras.mixin

        PROJECT_DIRECTORY = Pathname.new('../../../..').expand_path(__dir__)
        TEMP_DIRECTORY = PROJECT_DIRECTORY.join('tmp')

        def initialize(
          code,
          color_enabled:,
          super_diff_configuration: {},
          preserve_as_whole_file: false
        )
          @code = code.strip
          @color_enabled = color_enabled
          @super_diff_configuration = super_diff_configuration
          @preserve_as_whole_file = preserve_as_whole_file
        end

        def run
          result_of_command
        end

        protected

        def test_plan_prelude
          ''
        end

        def test_plan_command
          raise NotImplementedError
        end

        private

        attr_reader :code, :super_diff_configuration

        def color_enabled?
          @color_enabled
        end

        def preserve_as_whole_file?
          @preserve_as_whole_file
        end

        def result_of_command
          @result_of_command ||= if Process.respond_to?(:fork)
                                   result_of_command_with_fork
                                 else
                                   result_of_command_with_spawn
                                 end
        end

        def result_of_command_with_fork
          reader, writer = IO.pipe
          pid = Process.fork
          if pid
            # In the parent process, read and return the child RSpec's output.
            writer.close
            Process.wait(pid)
            rspec_output = reader.read
            @_result_of_command = Struct.new(:output).new(rspec_output)
          else
            # In the child process, reset RSpec to run the target test.
            ::RSpec.reset

            # NOTE: warnings_logger emits a newline to stdout with an after(:suite) hook
            ::RSpec::Core::Runner.run(
              ['--options', '/tmp/dummy-rspec-config', tempfile.to_s],
              writer,
              writer
            )
            writer.close
            Kernel.exit!(0)
          end
        end

        def tempfile
          @tempfile ||=
            begin
              TEMP_DIRECTORY.mkpath
              TEMP_DIRECTORY
                .join('integration_spec.rb')
                .tap { |file| file.write(program) }
            end
        end

        def program
          <<~PROGRAM
            require "#{PROJECT_DIRECTORY.join('support/test_plan.rb')}"

            test_plan = TestPlan.new(
              color_enabled: #{color_enabled?.inspect},
              super_diff_configuration: #{super_diff_configuration.inspect}
            )
            #{test_plan_prelude}
            test_plan.#{test_plan_command}

            #{minimal_program}
          PROGRAM
        end

        def minimal_program
          if preserve_as_whole_file?
            code
          else
            <<~PROGRAM
              RSpec.describe "test" do
                it "passes" do
                  RSpec::Expectations.configuration.on_potential_false_positives = :nothing
                  #{reindent(code, level: 2)}
                  RSpec::Expectations.configuration.on_potential_false_positives = true
                end
              end
            PROGRAM
          end
        end

        def reindent(code, level: 0)
          code.strip.split("\n").map { |line| ('  ' * level) + line }.join("\n")
        end
      end
    end
  end
end
