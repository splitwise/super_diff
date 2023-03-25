rails_dependencies =
  proc do
    gem "activerecord-jdbcsqlite3-adapter", platform: :jruby
    gem "jdbc-sqlite3", platform: :jruby
    gem "net-ftp"
    gem "combustion"
  end

appraisals = {
  rails_6_0:
    proc do
      instance_eval(&rails_dependencies)

      gem "rails", "~> 6.0.0"
      gem "sqlite3", "~> 1.4.0", platform: %i[ruby mswin mingw]
    end,
  rails_6_1:
    proc do
      instance_eval(&rails_dependencies)

      gem "rails", "~> 6.1.0"
      gem "sqlite3", "~> 1.4.0", platform: %i[ruby mswin mingw]
    end,
  rails_7_0:
    proc do
      instance_eval(&rails_dependencies)

      gem "rails", "~> 7.0.0"
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

rails_appraisals = %i[no_rails rails_6_0 rails_6_1 rails_7_0]
rspec_appraisals = %i[rspec_lt_3_10 rspec_gte_3_10]

rails_appraisals.each do |rails_appraisal|
  rspec_appraisals.each do |rspec_appraisal|
    appraise "#{rails_appraisal}_#{rspec_appraisal}" do
      instance_eval(&appraisals.fetch(rails_appraisal))
      instance_exec(
        rails_appraisal != :no_rails,
        &appraisals.fetch(rspec_appraisal)
      )
    end
  end
end
