require "bundler"
require "appraisal"
require "shellwords"

module SuperDiff
  class CurrentBundle
    include Singleton

    ROOT_DIR = Pathname.new("../..").expand_path(__dir__)
    APPRAISAL_GEMFILES_PATH = ROOT_DIR.join("gemfiles")

    def assert_appraisal!
      unless appraisal_in_use?
        raise AppraisalNotSpecified.new(<<~MESSAGE)
          Please run tests by specifying an appraisal, like:

              bundle exec appraisal <appraisal_name> #{current_command}

          Possible appraisals are:

          #{available_appraisals.map { |appraisal| "    - #{appraisal.name}" }.join("\n")}

          Or to simply go with the latest appraisal, use:

              bin/rspec #{shell_arguments}
        MESSAGE
      end
    end

    def current_appraisal
      if path
        available_appraisals.find do |appraisal|
          appraisal.gemfile_path == path.to_s
        end
      else
        nil
      end
    end

    def latest_appraisal
      available_appraisals.max_by(&:name)
    end

    private

    def appraisal_in_use?
      !current_appraisal.nil?
    end

    def path
      Bundler.default_gemfile
    end

    def available_appraisals
      @_available_appraisals ||= Appraisal::AppraisalFile.new.appraisals
    end

    def current_command
      Shellwords.join([File.basename($0)] + ARGV)
    end

    def shell_arguments
      Shellwords.join(ARGV)
    end

    class AppraisalNotSpecified < ArgumentError; end
  end
end
