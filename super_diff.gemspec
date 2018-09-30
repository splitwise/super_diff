require File.expand_path("../lib/super_diff/version", __FILE__)

Gem::Specification.new do |s|
  s.name        = "super_diff"
  s.version     = SuperDiff::VERSION
  s.authors     = ["Elliot Winkler"]
  s.email       = ["elliot.winkler@gmail.com"]
  s.homepage    = "https://github.com/mcmire/super_diff"
  s.summary     = "Diff complex data structures in Ruby, with helpful output."
  s.description = <<~DESC
    SuperDiff is a utility that helps you diff two complex data structures in
    Ruby, and gives you helpful output to show you exactly how the two data
    structures differ.
  DESC
  s.required_ruby_version = "~> 2.5"

  s.files         = ["README.md", "super_diff.gemspec"] + Dir["lib/**/*"]
  s.test_files    = Dir["spec/**/*"]
  s.executables   = Dir["exe/**/*"].map { |f| File.basename(f) }

  s.add_dependency "diff-lcs"
  s.add_dependency "patience_diff"
end
