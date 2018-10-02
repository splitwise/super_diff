RSpec::Expectations.instance_eval do
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

RSpec::Matchers::BuiltIn::Eq.class_eval do
  def failure_message
    "\n" +
      colorizer.wrap("expected: #{expected_formatted}\n", :failure) +
      colorizer.wrap("     got: #{actual_formatted}\n\n", :success) +
      colorizer.wrap("(compared using ==)\n", :detail)
  end

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

RSpec::Core::Formatters::SyntaxHighlighter.class_eval do
  private

  def implementation
    RSpec::Core::Formatters::SyntaxHighlighter::NoSyntaxHighlightingImplementation
  end
end
# rubocop:enable all
