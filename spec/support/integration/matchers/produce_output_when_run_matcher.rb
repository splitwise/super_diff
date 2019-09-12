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
        @output_processor = nil
      end

      def first_replacing(pattern, replacement)
        @output_processor = [pattern, replacement]
        self
      end

      def matches?(program)
        @program = program.strip
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

      attr_reader :expected_output, :program, :output_processor

      def actual_output
        @_actual_output ||= begin
          output = run_command.output.strip

          if output_processor
            output.gsub!(output_processor[0], output_processor[1])
          end

          output
        end
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
          TEMP_DIRECTORY.join("integration_spec.rb").
            tap { |tempfile| tempfile.write(program) }
      end
    end
  end
end
