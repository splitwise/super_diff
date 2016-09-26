require 'pp'
require 'super_diff/differ'
require 'super_diff/reporter'

module SuperDiff
  def self.diff(expected, actual, to: $stdout)
    change = Differ.diff(expected, actual)
    Reporter.report(change, to: to)
  end
end
