module SuperDiff
  module IntegrationTests
    def produce_output_when_run(output)
      ProduceOutputWhenRunMatcher.new(output)
    end

    class ProduceOutputWhenRunMatcher
      PROJECT_DIRECTORY = Pathname.new("../../../../../").expand_path(__FILE__)
      TEMP_DIRECTORY = PROJECT_DIRECTORY.join("tmp")

      def initialize(expected_output)
        @expected_output = expected_output.to_s.strip
      end

      def matches?(test)
        @test = test.strip
        TEMP_DIRECTORY.mkpath
        actual_output.include?(expected_output)
      end

      def failure_message
        message = "Expected test to produce output, but it did not.\n\n" +
          "Expected output to contain:\n\n" +
          CommandRunner::OutputHelpers.bookended(expected_output) +
          "\n" +
          "Actual output:\n\n" +
          CommandRunner::OutputHelpers.bookended(actual_output)

        ::RSpec::Matchers::ExpectedsForMultipleDiffs.
          from(expected_output).
          message_with_diff(
            message,
            ::RSpec::Expectations.differ,
            actual_output,
          )
      end

      private

      attr_reader :expected_output, :test

      def actual_output
        @_actual_output ||= run_command.output.strip
      end

      def run_command
        CommandRunner.run(
          "rspec",
          tempfile.to_s,
          env: { "DISABLE_PRY" => "true" },
        )
      end

      def tempfile
        @_tempfile =
          TEMP_DIRECTORY.join("acceptance_spec.rb").
            tap { |tempfile| tempfile.write(program) }
      end

      def program
        <<~PROGRAM
          $LOAD_PATH.unshift("#{PROJECT_DIRECTORY.join("lib")}")
          $LOAD_PATH.unshift("#{PROJECT_DIRECTORY}")

          begin
            require "pry-byebug"
          rescue LoadError
            require "pry-nav"
          end

          require "super_diff/rspec"

          require "spec/support/a"
          require "spec/support/person"
          require "spec/support/person_diff_formatter"
          require "spec/support/person_operation_sequence"
          require "spec/support/person_operational_sequencer"
          require "spec/support/shipping_address"

          RSpec.configure do |config|
            config.color_mode = :on
          end

          SuperDiff::RSpec.configure do |config|
            config.extra_operational_sequencer_classes << SuperDiff::Test::PersonOperationalSequencer
            config.extra_diff_formatter_classes << SuperDiff::Test::PersonDiffFormatter
          end

          RSpec.describe "test" do
            it "passes" do
          #{reindent(test, level: 2)}
            end
          end
        PROGRAM
      end

      def reindent(code, level: 0)
        code.strip.split("\n").map { |line| ("  " * level) + line }.join("\n")
      end
    end
  end
end
