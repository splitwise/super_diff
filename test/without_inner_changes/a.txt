require 'super_diff/differ'
require 'super_diff/reporter'

module SuperDiff
  def self.diff_to(expected, actual, stdout=$stdout)
    Differ.new.diff!(expected, actual).report_to(stdout)
  end
end

# For debugging purposes
require 'pp'
