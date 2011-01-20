require 'bundler'
Bundler::GemHelper.install_tasks

require 'rake/testtask'

desc "Run the tests"
Rake::TestTask.new(:test) do |t|
  t.test_files = FileList['test/**/*_test.rb']
end