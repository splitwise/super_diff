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
        @expect_output_to_contain_color = nil
      end

      def removing_object_ids
        first_replacing(/#<([\w:]+):0x[a-z0-9]+(.*?)>/, '#<\1\2>')
        self
      end

      def in_color(color_enabled)
        @expect_output_to_contain_color = color_enabled
        self
      end

      def matches?(program)
        @program = program.strip

        TEMP_DIRECTORY.mkpath

        output_matches? && presence_of_color_matches?
      end

      def failure_message
        if output_matches?
          "Expected output of test " +
            (expect_output_to_contain_color? ? "to " : "not to ") +
            "contain color, but " +
            (expect_output_to_contain_color? ? "it did not" : "it did") +
            "."
        else
          message =
            "Expected test to produce output, but it did not.\n\n" +
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
      end

      private

      attr_reader :expected_output, :program, :output_processor

      def expect_output_to_contain_color?
        @expect_output_to_contain_color
      end

      def first_replacing(pattern, replacement)
        @output_processor = [pattern, replacement]
        self
      end

      def output_matches?
        actual_output.include?(expected_output)
      end

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
          "rspec --options /tmp/dummy-rspec-config",
          tempfile.to_s,
          env: { "DISABLE_PRY" => "true" },
        )
      end

      def tempfile
        @_tempfile =
          TEMP_DIRECTORY.join("integration_spec.rb").
            tap { |tempfile| tempfile.write(program) }
      end

      def presence_of_color_matches?
        @expect_output_to_contain_color.nil? ||
          output_has_color? == expect_output_to_contain_color?
      end

      def output_has_color?
        !!(actual_output =~ /\e\[\d+m/)
      end
    end
  end
end
