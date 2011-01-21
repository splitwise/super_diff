module SuperDiff
  class Differ
    def initialize
    end
    
    def diff(expected, actual)
      expected_type = type_of(expected)
      actual_type   = type_of(actual)
      data = {
        :equal => (expected == actual),
        :expected => {:value => expected, :type => expected_type},
        :actual => {:value => actual, :type => actual_type},
        :common_type => (expected_type if expected_type == actual_type)
      }
      if expected.class == actual.class
        if expected.class == Array
          data[:breakdown] = []
          (0...expected.size).each do |i|
            data[:breakdown] << [i, diff(expected[i], actual[i])]
          end
        end
      end
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