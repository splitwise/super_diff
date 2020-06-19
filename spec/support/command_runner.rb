require "childprocess"

require "English"
require "shellwords"
require "timeout"

class CommandRunner
  class CommandFailedError < StandardError
    def self.create(command:, exit_status:, output:, message: nil)
      allocate.tap do |error|
        error.command = command
        error.exit_status = exit_status
        error.output = output
        error.__send__(:initialize, message)
      end
    end

    attr_accessor :command, :exit_status, :output

    def initialize(message = nil)
      super(message || build_message)
    end

    private

    def build_message
      message = <<-MESSAGE
Command #{command.inspect} failed, exiting with status #{exit_status}.
      MESSAGE

      if output
        message << <<-MESSAGE
Output:
#{
  SuperDiff::Test::OutputHelpers.divider("START") +
  output +
  SuperDiff::Test::OutputHelpers.divider("END")
}
        MESSAGE
      end

      message
    end
  end

  class CommandTimedOutError < StandardError
    def self.create(command:, timeout:, output:, message: nil)
      allocate.tap do |error|
        error.command = command
        error.timeout = timeout
        error.output = output
        error.__send__(:initialize, message)
      end
    end

    attr_accessor :command, :timeout, :output

    def initialize(message = nil)
      super(message || build_message)
    end

    private

    def build_message
      message = <<-MESSAGE
Command #{formatted_command.inspect} timed out after #{timeout} seconds.
      MESSAGE

      if output
        message << <<-MESSAGE
Output:
#{
  SuperDiff::Test::OutputHelpers.divider("START") +
  output +
  SuperDiff::Test::OutputHelpers.divider("END")
}
        MESSAGE
      end

      message
    end
  end

  def self.run(*args)
    new(*args).tap do |runner|
      yield runner if block_given?
      runner.run
    end
  end

  def self.run!(*args)
    run(*args) do |runner|
      runner.run_successfully = true
      yield runner if block_given?
    end
  end

  attr_reader :status, :options, :env
  attr_accessor :run_quickly, :run_successfully, :retries,
    :timeout

  def initialize(*args)
    @reader, @writer = IO.pipe
    options = (args.last.is_a?(Hash) ? args.pop : {})
    @args = args
    @options = options.merge(
      err: [:child, :out],
      out: @writer,
    )
    @env = extract_env_from(@options)

    @process = ChildProcess.build(*command)
    @env.each do |key, value|
      @process.environment[key] = value
    end
    @process.io.stdout = @process.io.stderr = @writer

    @wrapper = -> (block) { block.call }
    self.directory = Dir.pwd
    @run_quickly = false
    @run_successfully = false
    @retries = 1
    @num_times_run = 0
    @timeout = 10
  end

  def around_command(&block)
    @wrapper = block
  end

  def directory
    @options[:chdir]
  end

  def directory=(directory)
    @options[:chdir] = (directory || Dir.pwd).to_s
  end

  def formatted_command
    [formatted_env, Shellwords.join(command)].
      reject(&:empty?).
      join(" ")
  end

  def run
    possibly_running_quickly do
      run_with_debugging

      if run_successfully && !success?
        fail!
      end
    end

    self
  end

  def stop
    if !writer.closed?
      writer.close
    end
  end

  def output
    @_output ||= begin
      stop
      reader.read
    end
  end

  def elided_output
    lines = output.split(/\n/)
    new_lines = lines[0..4]

    if lines.size > 10
      new_lines << "(...#{lines.size - 10} more lines...)"
    end

    new_lines << lines[-5..-1]
    new_lines.join("\n")
  end

  def success?
    status.success?
  end

  def exit_status
    status.exitstatus
  end

  def fail!
    raise CommandFailedError.create(
      command: formatted_command,
      exit_status: exit_status,
      output: output,
    )
  end

  def has_output?(expected_output)
    if expected_output.is_a?(Regexp)
      output =~ expected_output
    else
      output.include?(expected_output)
    end
  end

  protected

  attr_reader :args, :reader, :writer, :wrapper, :process

  private

  def extract_env_from(options)
    options.delete(:env) { {} }.reduce({}) do |hash, (key, value)|
      hash.merge(key.to_s => value)
    end
  end

  def command
    args.flatten.flat_map { |word| Shellwords.split(word) }
  end

  def formatted_env
    env.map { |key, value| "#{key}=#{value.inspect}" }.join(" ")
  end

  def run_freely
    process.start
    process.wait
  end

  def run_with_wrapper
    wrapper.call(method(:run_freely))
  end

  def run_with_debugging
    debug { "\n\e[33mChanging to directory:\e[0m #{directory}" }
    debug { "\e[32mRunning command:\e[0m #{formatted_command}" }

    run_with_wrapper

    debug do
      "\n" +
        SuperDiff::Test::OutputHelpers.divider("START") +
        output +
        SuperDiff::Test::OutputHelpers.divider("END")
    end
  end

  def possibly_running_quickly(&block)
    if run_quickly
      begin
        Timeout.timeout(timeout, &block)
      rescue Timeout::Error
        stop

        raise CommandTimedOutError.create(
          command: formatted_command,
          timeout: timeout,
          output: output,
        )
      end
    else
      yield
    end
  end

  def debugging_enabled?
    ENV["DEBUG_COMMANDS"] == "1"
  end

  def debug
    if debugging_enabled?
      puts yield
    end
  end
end
