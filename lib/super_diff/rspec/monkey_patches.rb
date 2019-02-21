SuperDiff::Helpers.module_eval do
  # UPDATE: Replace the default implementation with one that makes use of
  # #values_match? in RSpec::Matchers::Composable, which accounts for matcher
  # objects
  def self.values_equal?(expected, actual)
    rspec_composable.values_match?(expected, actual)
  end

  def self.rspec_composable
    @_rspec_composable ||= Object.new.tap do |object|
      object.singleton_class.class_eval do
        include RSpec::Matchers::Composable
        public :values_match?
      end
    end
  end
  private_class_method :rspec_composable
end

RSpec::Expectations.instance_eval do
  # UPDATE: Replace the default differ class with our own
  def differ
    SuperDiff::RSpec::Differ
  end
end

# rubocop:disable all
RSpec::Core::Formatters::ConsoleCodes.instance_eval do
  # UPDATE: Patch so it returns nothing if code_or_symbol is nil
  def console_code_for(code_or_symbol)
    if code_or_symbol
      if (config_method = config_colors_to_methods[code_or_symbol])
        console_code_for RSpec.configuration.__send__(config_method)
      elsif RSpec::Core::Formatters::ConsoleCodes::VT100_CODE_VALUES.key?(code_or_symbol)
        code_or_symbol
      else
        RSpec::Core::Formatters::ConsoleCodes::VT100_CODES.fetch(code_or_symbol) do
          console_code_for(:white)
        end
      end
    end
  end

  # UPDATE: Patch so it does not apply a color if code_or_symbol is nil
  def wrap(text, code_or_symbol)
    if RSpec.configuration.color_enabled? && code = console_code_for(code_or_symbol)
      "\e[#{code}m#{text}\e[0m"
    else
      text
    end
  end
end

RSpec::Core::Formatters::ExceptionPresenter.class_eval do
  # UPDATE: Copy from SyntaxHighlighter::CodeRayImplementation
  RESET_CODE = "\e[0m"

  def initialize(exception, example, options={})
    @exception               = exception
    @example                 = example
    # UPDATE: Use no color by default
    @message_color           = options[:message_color]
    @description             = options.fetch(:description)            { example.full_description }
    @detail_formatter        = options.fetch(:detail_formatter)       { Proc.new {} }
    @extra_detail_formatter  = options.fetch(:extra_detail_formatter) { Proc.new {} }
    @backtrace_formatter     = options.fetch(:backtrace_formatter)    { RSpec.configuration.backtrace_formatter }
    @indentation             = options.fetch(:indentation, 2)
    @skip_shared_group_trace = options.fetch(:skip_shared_group_trace, false)
    @failure_lines           = options[:failure_lines]
  end

  def add_shared_group_lines(lines, colorizer)
    return lines if @skip_shared_group_trace

    example.metadata[:shared_group_inclusion_backtrace].each do |frame|
      # Update: Use red instead of the default color
      lines << colorizer.wrap(frame.description, :failure)
    end

    lines
  end

  # UPDATE: Style the first part in blue and the snippet of the line that failed
  # in white
  def failure_slash_error_lines
    lines = read_failed_lines

    failure_slash_error = RSpec::Core::Formatters::ConsoleCodes.wrap(
      "Failure/Error: ",
      :detail
    )

    if lines.count == 1
      lines[0] =
        failure_slash_error +
        RSpec::Core::Formatters::ConsoleCodes.wrap(lines[0].strip, :white)
    else
      least_indentation =
        RSpec::Core::Formatters::SnippetExtractor.least_indentation_from(lines)
      lines = lines.map do |line|
        RSpec::Core::Formatters::ConsoleCodes.wrap(
          line.sub(/^#{least_indentation}/, '  '),
          :white
        )
      end
      lines.unshift(failure_slash_error)
    end

    lines
  end
end

RSpec::Matchers::BuiltIn::BaseMatcher.class_eval do
  # UPDATE: Colorize the 'actual' value
  def failure_message
    "expected %s to %s".dup % [
      colorizer.wrap(description_of(@actual), :success),
      description(colorize_value_with: :failure)
    ]
  end

  # UPDATE: Colorize the 'actual' value
  def failure_message_when_negated
    "expected %s not to %s".dup % [
      colorizer.wrap(description_of(@actual), :success),
      description(colorize_value_with: :failure)
    ]
  end

  private

  def colorizer
    RSpec::Core::Formatters::ConsoleCodes
  end
end

RSpec::Matchers::BuiltIn::Eq.class_eval do
  # UPDATE: Colorize the 'expected' and 'actual' values
  def failure_message
    "\n" +
      colorizer.wrap("expected: #{expected_formatted}\n", :failure) +
      colorizer.wrap("     got: #{actual_formatted}\n\n", :success) +
      colorizer.wrap("(compared using ==)\n", :detail)
  end

  # UPDATE: Colorize the 'expected' and 'actual' values
  def failure_message_when_negated
    "\n" +
      colorizer.wrap("expected: value != #{expected_formatted}\n", :failure) +
      colorizer.wrap("     got: #{actual_formatted}\n\n", :success) +
      colorizer.wrap("(compared using ==)\n", :detail)
  end

  private

  def colorizer
    RSpec::Core::Formatters::ConsoleCodes
  end
end

RSpec::Matchers::BuiltIn::HaveAttributes.class_eval do
  # UPDATE: Colorize the 'expected' value
  def description(colorize_value_with: nil)
    described_items = surface_descriptions_in(expected)
    message = "have attributes %s" % [
      colorizer.wrap(
        RSpec::Support::ObjectFormatter.format(described_items),
        colorize_value_with
      )
    ]
    improve_hash_formatting(message)
  end

  # UPDATE: Colorize the 'actual' value
  def failure_message
    respond_to_failure_message_or do
      "expected %s to %s but had attributes %s" % [
        colorizer.wrap(actual_formatted, :success),
        description(colorize_value_with: :failure),
        colorizer.wrap(formatted_values, :detail)
      ]
    end
  end

  # UPDATE: Colorize the 'actual' value
  def failure_message_when_negated
    respond_to_failure_message_or do
      "expected %s not to %s" % [
        colorizer.wrap(actual_formatted, :success),
        description(colorize_value_with: :failure)
      ]
    end
  end
end

RSpec::Matchers::BuiltIn::Match.class_eval do
  # UPDATE: Colorize the 'expected' value
  def description(colorize_value_with: nil)
    if @expected_captures && @expected.match(actual)
      "match %s with captures %s" % [
        colorizer.wrap(
          surface_descriptions_in(expected).inspect,
          colorize_value_with
        ),
        colorizer.wrap(
          surface_descriptions_in(@expected_captures).inspect,
          :detail
        )
      ]
    else
      "match %s" % [
        colorizer.wrap(
          surface_descriptions_in(expected).inspect,
          colorize_value_with
        )
      ]
    end
  end
end

# UPDATE: Don't syntax-highlight code snippets displayed in failure messages
RSpec::Core::Formatters::SyntaxHighlighter.class_eval do
  private

  def implementation
    RSpec::Core::Formatters::SyntaxHighlighter::NoSyntaxHighlightingImplementation
  end
end

RSpec::Mocks::ErrorGenerator.class_eval do
  def default_error_message(expectation, expected_args, actual_args)
    [
      colorizer.wrap(
        "#{intro} received #{expectation.message.inspect}",
        :detail
      ),
      " #{unexpected_arguments_message(expected_args, actual_args)}".dup,
    ].join
  end

  private

  def unexpected_arguments_message(expected_args_string, actual_args_string)
    [
      colorizer.wrap(
        "with unexpected arguments\n  ",
        :detail
      ),
      colorizer.wrap(
        "expected: #{expected_args_string}\n       ",
        :failure
      ),
      colorizer.wrap(
        "got: #{actual_args_string}",
        :success
      )
    ].join
  end

  def colorizer
    RSpec::Core::Formatters::ConsoleCodes
  end
end

RSpec::Matchers::ExpectedsForMultipleDiffs.class_eval do
  # UPDATE: Add an extra line break
  def message_with_diff(message, differ, actual)
    diff = diffs(differ, actual)
    message = "#{message}\n\n#{diff}" unless diff.empty?
    message
  end

  private

  # UPDATE: Add extra line breaks in between diffs
  def diffs(differ, actual)
    @expected_list.map do |(expected, diff_label)|
      diff = differ.diff(actual, expected)
      next if diff.strip.empty?
      RSpec::Core::Formatters::ConsoleCodes.wrap(diff_label, :white) + diff
    end.compact.join("\n\n")
  end
end
# rubocop:enable all
