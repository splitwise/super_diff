module SuperDiff
  module Test
    def self.jruby?
      defined?(JRUBY_VERSION)
    end
  end
end
