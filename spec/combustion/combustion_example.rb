# Set up Combustion as close to https://github.com/pat/combustion#usage as possible

require 'bundler'

Bundler.require :default, :development

require "combustion"

Combustion.initialize! :action_controller

require "rspec/rails"
require "super_diff"
require "super_diff/rails"

# It doesn't actually matter that there are no rspec or combustion based tests. By now the problem
# will have already happened or not.
