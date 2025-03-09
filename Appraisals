# frozen_string_literal: true

rails_dependencies =
  proc do
    gem 'activerecord-jdbcsqlite3-adapter', platform: :jruby
    gem 'jdbc-sqlite3', platform: :jruby
    gem 'net-ftp'
    gem 'combustion'
  end

appraisals = {
  rails_6_1:
    proc do
      instance_eval(&rails_dependencies)

      gem 'rails', '~> 6.1.0'
      gem 'sqlite3', '~> 1.4.0', platform: %i[ruby mswin mingw]
    end,
  rails_7_0:
    proc do
      instance_eval(&rails_dependencies)

      gem 'rails', '~> 7.0.0'
      gem 'sqlite3', '~> 1.4.0', platform: %i[ruby mswin mingw]
    end,
  rails_7_1:
    proc do
      instance_eval(&rails_dependencies)

      gem 'rails', '~> 7.1.0'
      gem 'sqlite3', '~> 1.4.0', platform: %i[ruby mswin mingw]
    end,
  rails_7_2:
    proc do
      instance_eval(&rails_dependencies)

      gem 'rails', '~> 7.2.0'
      gem 'sqlite3', '~> 1.4.0', platform: %i[ruby mswin mingw]
    end,
  rails_8_0:
    proc do
      instance_eval(&rails_dependencies)

      gem 'rails', '~> 8.0.0'
      gem 'sqlite3', '>= 2.1', platform: %i[ruby mswin mingw]
    end,
  no_rails: proc {},
  rspec_lt_3_10:
    proc do |with_rails|
      version = '~> 3.9.0'

      gem 'rspec', version

      gem 'rspec-rails' if with_rails
    end,
  rspec_gte_3_10:
    proc do |with_rails|
      # gem "rspec", *version

      gem 'rspec', '3.12.0'
      gem 'rspec-core', '3.12.0'
      gem 'rspec-expectations', '3.12.3'
      gem 'rspec-mocks', '3.12.0'
      gem 'rspec-support', '3.12.0'

      gem 'rspec-rails' if with_rails
    end,
  rspec_gte_3_13:
    proc do |with_rails|
      # version = ['>= 3.13', '< 4']
      # gem "rspec", *version

      gem 'rspec', '3.13.0'
      gem 'rspec-core', '3.13.0'
      gem 'rspec-expectations', '3.13.0'
      gem 'rspec-mocks', '3.13.0'
      gem 'rspec-support', '3.13.0'

      gem 'rspec-rails' if with_rails
    end
}

rails_appraisals = %i[no_rails rails_6_1 rails_7_0 rails_7_1 rails_7_2 rails_8_0]
rspec_appraisals = %i[rspec_lt_3_10 rspec_gte_3_10 rspec_gte_3_13]

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
