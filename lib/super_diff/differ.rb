module SuperDiff
  class Differ
    def initialize
    end
    
    def diff(expected, actual)
      expected_type = type_of(expected)
      actual_type   = type_of(actual)
      same_type     = (expected_type == actual_type)
      data = {}
      if same_type && expected.class < Enumerable
        if expected.class == Array
          equal = true
          data[:breakdown] = []
          (0...expected.size).each do |i|
            diff = diff(expected[i], actual[i])
            data[:breakdown] << [i, diff]
            equal &&= diff[:equal]
          end
        end
      else
        equal = (expected == actual)
      end
      data.merge!(
        :equal => equal,
        :expected => {:value => expected, :type => expected_type},
        :actual => {:value => actual, :type => actual_type},
        :common_type => (expected_type if same_type)
      )
      data
    end
    
  private
    def type_of(value)
      case value
        when Fixnum then :number
        else value.class.to_s.downcase.to_sym
      end
    end
  end
end