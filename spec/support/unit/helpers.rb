# frozen_string_literal: true

module SuperDiff
  module UnitTests
    extend self

    def with_configuration(configuration)
      old_configuration = SuperDiff.configuration.dup
      SuperDiff.configuration.merge!(configuration)
      yield.tap { SuperDiff.configuration.merge!(old_configuration) }
    end

    def colored(...)
      SuperDiff::Core::Helpers.style(...).to_s.chomp
    end

    def capture_warnings
      fake_stderr = StringIO.new
      original_stderr = $stderr
      $stderr = fake_stderr
      yield
      $stderr = original_stderr
      fake_stderr.string
    end
  end
end
