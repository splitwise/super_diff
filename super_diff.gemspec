# frozen_string_literal: true

require File.expand_path('lib/super_diff/version', __dir__)

Gem::Specification.new do |s|
  s.name = 'super_diff'
  s.version = SuperDiff::VERSION
  s.authors = ['Elliot Winkler', 'Splitwise, Inc.']
  s.email = ['oss-community@splitwise.com']
  s.homepage = 'https://github.com/splitwise/super_diff'
  s.summary =
    'A better way to view differences between complex data structures in RSpec.'
  s.license = 'MIT'
  s.description = <<~DESC
    SuperDiff is a gem that hooks into RSpec to intelligently display the
    differences between two data structures of any type.
  DESC
  s.metadata = {
    'bug_tracker_uri' => 'https://github.com/splitwise/super_diff/issues',
    'changelog_uri' =>
      'https://github.com/splitwise/super_diff/blob/main/CHANGELOG.md',
    'rubygems_mfa_required' => 'true',
    'source_code_uri' => 'https://github.com/splitwise/super_diff'
  }
  s.required_ruby_version = '>= 3.0'

  s.files = %w[README.md super_diff.gemspec] + Dir['lib/**/*']
  s.executables = Dir['exe/**/*'].map { |f| File.basename(f) }

  s.add_dependency 'attr_extras', '>= 6.2.4'
  s.add_dependency 'diff-lcs'
  s.add_dependency 'patience_diff'
end
