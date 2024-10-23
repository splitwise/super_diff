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
          @result_of_command ||=
            if zeus_running?
              Bundler.with_unbundled_env do
                CommandRunner.run(Shellwords.join(command))
              end
            else
              CommandRunner.run(
                Shellwords.join(command),
                env: {
                  'DISABLE_PRY' => 'true'
                }
              )
            end
        end

        def command
          raise 'RAILS_ENV is being set somehow?!' if ENV['RAILS_ENV']

          if zeus_running?
            [
              'zeus',
              test_plan_command,
              color_option,
              '--no-pry',
              tempfile.to_s,
              '--super-diff-configuration',
              JSON.generate(super_diff_configuration)
            ]
          else
            ['rspec', '--options', '/tmp/dummy-rspec-config', tempfile.to_s]
          end
        end

        def zeus_running?
          PROJECT_DIRECTORY.join('.zeus.sock').exist?
        end

        def color_option
          color_enabled? ? '--color' : '--no-color'
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
          if zeus_running?
            minimal_program
          else
            <<~PROGRAM
              require "#{PROJECT_DIRECTORY.join('support/test_plan.rb')}"

              test_plan = TestPlan.new(
                using_outside_of_zeus: true,
                color_enabled: #{color_enabled?.inspect},
                super_diff_configuration: #{super_diff_configuration.inspect}
              )
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
