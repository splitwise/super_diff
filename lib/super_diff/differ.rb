module SuperDiff
  class Differ
    def initialize
    end
    
    def diff(expected, actual)
      data = {
        :equal => (expected == actual),
        :expected => {:value => expected, :type => type_of(expected)},
        :actual => {:value => actual, :type => type_of(actual)}
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