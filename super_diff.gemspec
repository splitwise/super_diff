# -*- encoding: utf-8 -*-
require File.expand_path("../lib/super_diff/version", __FILE__)

Gem::Specification.new do |s|
  s.name        = "super_diff"
  s.version     = SuperDiff::VERSION
  s.platform    = Gem::Platform::RUBY
  s.authors     = ["Elliot Winkler"]
  s.email       = ["elliot.winkler@gmail.com"]
  s.homepage    = "http://github.com/mcmire/super_diff"
  s.summary     = %q{Diff complex data structures in Ruby, with helpful output.}
  s.description = %q{SuperDiff is a utility that helps you diff two complex data structures in Ruby, and gives you helpful output to show you exactly how the two data structures differ.}

  #s.rubyforge_project = "super_diff"

  s.files         = ["README.md", "super_diff.gemspec"] + Dir["lib/**/*"]
  s.test_files    = Dir["{test,spec,features}/**/*"]
  s.executables   = Dir["bin/**/*"].map {|f| File.basename(f) }
  s.require_paths = ["lib"]
  
  s.add_development_dependency "rspec-core"
  s.add_development_dependency "rspec-expectations"
  s.add_development_dependency "guard-rspec"
  s.add_development_dependency "rb-fsevent"
  s.add_development_dependency "growl"
  s.add_development_dependency "ghi"
end
