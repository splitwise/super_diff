require File.expand_path("lib/super_diff/version", __dir__)

Gem::Specification.new do |s|
  s.name = "super_diff"
  s.version = SuperDiff::VERSION
  s.authors = ["Elliot Winkler"]
  s.email = ["elliot.winkler@gmail.com"]
  s.homepage = "https://github.com/mcmire/super_diff"
  s.summary =
    "A better way to view differences between complex data structures in RSpec."
  s.license = "MIT"
  s.description = <<~DESC
    SuperDiff is a gem that hooks into RSpec to intelligently display the
    differences between two data structures of any type.
  DESC
  s.required_ruby_version = [">= 2.4", "< 4"]

  s.files = %w[README.md super_diff.gemspec] + Dir["lib/**/*"]
  s.test_files = Dir["spec/**/*"]
  s.executables = Dir["exe/**/*"].map { |f| File.basename(f) }

  s.add_dependency "attr_extras", ">= 6.2.4"
  s.add_dependency "diff-lcs"
  s.add_dependency "patience_diff"
end
