require "bundler"
require "appraisal"
require "shellwords"

module SuperDiff
  module Test
    class CurrentBundle
      include Singleton

      AppraisalNotSpecified = Class.new(ArgumentError)

      def assert_appraisal!
        unless appraisal_in_use?
          message = <<~MESSAGE
            Please run tests by specifying an Appraisal, like:

                bundle exec appraisal <appraisal_name> #{current_command}

            Possible appraisals are:

            #{available_appraisals.map { |x| "- #{x}\n" }.join}
          MESSAGE
          raise AppraisalNotSpecified, message
        end
      end

      def current_command
        Shellwords.join([File.basename($0)] + ARGV)
      end

      def appraisal_in_use?
        path.dirname == root.join("gemfiles")
      end

      def current_or_latest_appraisal
        current_appraisal || latest_appraisal
      end

      def latest_appraisal
        available_appraisals.max
      end

      def available_appraisals
        Appraisal::AppraisalFile.each.map(&:name)
      end

      private

      def current_appraisal
        if appraisal_in_use?
          File.basename(path, ".gemfile")
        end
      end

      def path
        Bundler.default_gemfile
      end

      def root
        Pathname.new("../..").expand_path(__dir__)
      end
    end
  end
end
