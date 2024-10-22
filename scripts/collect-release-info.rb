#!/usr/bin/env ruby
# frozen_string_literal: true

github_output = File.open(ENV.fetch('GITHUB_OUTPUT'), 'a')

spec = Gem::Specification.load('super_diff.gemspec')
current_version = spec.version

latest_version = Gem.latest_version_for('super_diff')

puts "Current version is #{current_version}, latest version is #{latest_version}"

if current_version == latest_version
  puts "This isn't a new release."
  github_output.puts('IS_NEW_RELEASE=false')
else
  puts 'Looks like a new release!'
  github_output.puts('IS_NEW_RELEASE=true')
  github_output.puts("RELEASE_VERSION=#{current_version}")
end
