# frozen_string_literal: true

class RSpecForkedRunner
  def initialize(rspec_options:)
    @rspec_options = rspec_options
  end

  # Load relevant dependencies before calling `#run`.
  # Otherwise, the performance gain of running RSpec in a forked process is diminished.
  def run
    @reader, @writer = IO.pipe
    pid = Process.fork

    if pid
      output = run_parent(child_pid: pid)
      CommandRunner::Result.new(output: output)
    else
      run_child
    end
  end

  private

  def run_parent(child_pid:)
    # In the parent process, read and return the child RSpec's output.
    writer.close
    Process.wait(child_pid)
    reader.read
  end

  def run_child
    # In the child process, reset RSpec to run the target test.
    ::RSpec.reset

    ::RSpec::Core::Runner.run(
      rspec_options,
      writer,
      writer
    )
    writer.close
    Kernel.exit!(0)
  end

  attr_reader :reader, :writer, :rspec_options
end
