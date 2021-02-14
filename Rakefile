require "bundler/gem_tasks"

require_relative "support/current_bundle"

begin
  require "rspec/core/rake_task"
  RSpec::Core::RakeTask.new(spec: :before_spec) do |config|
    config.verbose = true
  end
rescue LoadError
  task :spec do
    appraisal = SuperDiff::CurrentBundle.instance.latest_appraisal
    exec "appraisal #{appraisal.name} rake spec --trace"
  end
end

task :default do
  if SuperDiff::CurrentBundle.instance.appraisal_in_use?
    sh "rake spec"
  elsif ENV["CI"]
    exec "appraisal rake --trace"
  else
    appraisal = SuperDiff::CurrentBundle.instance.latest_appraisal
    exec "appraisal #{appraisal.name} rake --trace"
  end
end

task :before_spec do
  FileUtils.rm_rf(File.expand_path("./spec/tmp", __dir__))
end
