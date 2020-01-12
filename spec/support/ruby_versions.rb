module SuperDiff
  module Test
    def self.jruby?
      defined?(JRUBY_VERSION)
    end

    def self.version_match?(version_string)
      Gem::Requirement.new(version_string).satisfied_by?(Gem::Version.new(RUBY_VERSION))
    end
  end
end
