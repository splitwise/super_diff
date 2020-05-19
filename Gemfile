# frozen_string_literal: true

source "https://rubygems.org"

git_source(:github) { |repo_name| "https://github.com/#{repo_name}" }

gem "appraisal"
gem(
  "attr_extras",
  github: "mcmire/attr_extras",
  branch: "pass-kwargs-in-explicit-static-facade",
)
gem "childprocess"
gem "pry-byebug", platform: :mri
gem "pry-nav", platform: :jruby
gem "rake"
gem "rspec"
gem "rubocop"

gemspec
