# frozen_string_literal: true

require 'delegate'
require 'super_diff'

class FakeTTYDecorator < SimpleDelegator
  def initialize(obj, is_tty:)
    super(obj)
    @is_tty = is_tty
  end

  def isatty = @is_tty
  def tty? = isatty
end

RSpec.describe SuperDiff::Core::Configuration, with_superdiff_rspec: false do
  describe '#color_enabled?' do
    it 'is true when stdout is a TTY' do
      original_stdout = $stdout
      color_enabled = nil
      begin
        $stdout = FakeTTYDecorator.new(StringIO.new, is_tty: true)
        color_enabled = SuperDiff.configuration.color_enabled?
      ensure
        $stdout = original_stdout
      end
      expect(color_enabled).to be(true)
    end

    it 'is false when stdout is not a TTY but we are in CI' do
      original_stdout = $stdout
      original_ci = ENV.fetch('CI', nil)
      color_enabled = nil
      begin
        $stdout = FakeTTYDecorator.new(StringIO.new, is_tty: false)
        ENV['CI'] = 'true'
        color_enabled = SuperDiff.configuration.color_enabled?
      ensure
        $stdout = original_stdout
        ENV['CI'] = original_ci
      end
      expect(color_enabled).to be(true)
    end

    it 'is false when stdout is not a TTY and we are not in CI' do
      original_stdout = $stdout
      original_ci = ENV.fetch('CI', nil)
      color_enabled = nil
      begin
        $stdout = FakeTTYDecorator.new(StringIO.new, is_tty: false)
        ENV['CI'] = nil
        color_enabled = SuperDiff.configuration.color_enabled?
      ensure
        $stdout = original_stdout
        ENV['CI'] = original_ci
      end
      expect(color_enabled).to be(false)
    end
  end
end
