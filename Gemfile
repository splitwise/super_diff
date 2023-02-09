# frozen_string_literal: true

source "https://rubygems.org"

git_source(:github) { |repo_name| "https://github.com/#{repo_name}" }

gem "appraisal", github: 'thoughtbot/appraisal', ref: '2f5be65b8e127bd602fd149f395f2f8fa50616a8'
gem "childprocess"
gem "climate_control"
# pry-byebug 3.10.0 drops support for Ruby 2.6 :(
gem "pry-byebug", "3.9.0", platform: :mri
gem "pry-nav", platform: :jruby
gem "rake"
gem "rubocop"
gem "warnings_logger"

gemspec
