common_dependencies = proc do
  gem "activerecord-jdbcsqlite3-adapter", platform: :jruby
  gem "jdbc-sqlite3", platform: :jruby
end

appraise "rails_5_0" do
  instance_eval(&common_dependencies)

  gem "activerecord", "~> 5.0.0"
  gem "sqlite3", "~> 1.3.6", platform: [:ruby, :mswin, :mingw]
end

appraise "rails_5_1" do
  instance_eval(&common_dependencies)

  gem "activerecord", "~> 5.1.0"
  gem "sqlite3", "~> 1.3.6", platform: [:ruby, :mswin, :mingw]
end

appraise "rails_5_2" do
  instance_eval(&common_dependencies)

  gem "activerecord", "~> 5.2.0"
  gem "sqlite3", "~> 1.3.6", platform: [:ruby, :mswin, :mingw]
end

if Gem::Requirement.new(">= 2.5.0").satisfied_by?(Gem::Version.new(RUBY_VERSION))
  appraise "rails_6_0" do
    instance_eval(&common_dependencies)

    gem "activerecord", "~> 6.0"
    gem "sqlite3", "~> 1.4.0", platform: [:ruby, :mswin, :mingw]
  end
end
