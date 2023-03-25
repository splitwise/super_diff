rails_dependencies =
  proc do
    gem "activerecord-jdbcsqlite3-adapter", platform: :jruby
    gem "jdbc-sqlite3", platform: :jruby
    install_if '-> { Gem::Requirement.new(">= 2.6.0").satisfied_by?(Gem::Version.new(RUBY_VERSION)) }' do
      gem "net-ftp"
    end
  end

appraisals = {
  rails_5_0:
    proc do
      instance_eval(&rails_dependencies)

      gem "activerecord", "~> 5.0.0"
      gem "railties", "~> 5.0.0"
      gem "sqlite3", "~> 1.3.6", platform: %i[ruby mswin mingw]
    end,
  rails_5_1:
    proc do
      instance_eval(&rails_dependencies)

      gem "activerecord", "~> 5.1.0"
      gem "railties", "~> 5.1.0"
      gem "sqlite3", "~> 1.3.6", platform: %i[ruby mswin mingw]
    end,
  rails_5_2:
    proc do
      instance_eval(&rails_dependencies)

      gem "activerecord", "~> 5.2.0"
      gem "railties", "~> 5.2.0"
      gem "sqlite3", "~> 1.3.6", platform: %i[ruby mswin mingw]
    end,
  rails_6_0:
    proc do
      instance_eval(&rails_dependencies)

      gem "activerecord", "~> 6.0.0"
      gem "railties", "~> 6.0.0"
      gem "sqlite3", "~> 1.4.0", platform: %i[ruby mswin mingw]
    end,
  rails_6_1:
    proc do
      instance_eval(&rails_dependencies)

      gem "activerecord", "~> 6.1.0"
      gem "railties", "~> 6.1.0"
      gem "sqlite3", "~> 1.4.0", platform: %i[ruby mswin mingw]
    end,
  rails_7_0:
    proc do
      instance_eval(&rails_dependencies)

      gem "activerecord", "~> 7.0.0"
      gem "railties", "~> 7.0.0"
      gem "sqlite3", "~> 1.4.0", platform: %i[ruby mswin mingw]
    end,
  no_rails: proc {},
  rspec_lt_3_10:
    proc do |with_rails|
      version = "~> 3.9.0"

      gem "rspec", version

      gem "rspec-rails" if with_rails
    end,
  rspec_gte_3_10:
    proc do |with_rails|
      version = [">= 3.10", "< 4"]

      gem "rspec", *version

      gem "rspec-rails" if with_rails
    end
}

rails_appraisals = [:no_rails]

if Gem::Requirement.new("< 3").satisfied_by?(Gem::Version.new(RUBY_VERSION))
  rails_appraisals << :rails_5_0
  rails_appraisals << :rails_5_1
  rails_appraisals << :rails_5_2
end

if Gem::Requirement.new(">= 2.5.0").satisfied_by?(
     Gem::Version.new(RUBY_VERSION)
   )
  rails_appraisals << :rails_6_0
  rails_appraisals << :rails_6_1
end

if Gem::Requirement.new(">= 2.7.0").satisfied_by?(
     Gem::Version.new(RUBY_VERSION)
   )
  rails_appraisals << :rails_7_0
end

rspec_appraisals = %i[rspec_lt_3_10 rspec_gte_3_10]

rails_appraisals.each do |rails_appraisal|
  rspec_appraisals.each do |rspec_appraisal|
    if rails_appraisal == :no_rails
      appraise "#{rails_appraisal}_#{rspec_appraisal}" do
        instance_eval(&appraisals.fetch(rails_appraisal))
        instance_exec(false, &appraisals.fetch(rspec_appraisal))
      end
    elsif %i[rails_6_1 rails_7_0].include?(rails_appraisal) &&
          rspec_appraisal == :rspec_lt_3_10
      next
    else
      appraise "#{rails_appraisal}_#{rspec_appraisal}" do
        instance_eval(&appraisals.fetch(rails_appraisal))
        instance_exec(true, &appraisals.fetch(rspec_appraisal))
      end
    end
  end
end
