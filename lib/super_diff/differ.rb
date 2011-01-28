module SuperDiff
  class Differ
    def diff!(expected, actual)
      @data = diff(expected, actual)
      self
    end
    
    def diff(expected, actual)
      _diff(:expected => expected, :actual => actual)
    end
    
    def report_to(stdout, data=@data)
      Reporter.new(stdout).report(data)
    end
    alias :report :report_to
    
  private
    def _diff(args)
      data = {:expected => nil, :actual => nil, :common_type => nil}
      data[:expected] = value_data_for(args[:expected]) if args[:expected]
      data[:actual] = value_data_for(args[:actual]) if args[:actual]
      if data[:expected] && data[:actual] && data[:expected][:type] == data[:actual][:type]
        data[:common_type] = data[:expected][:type]
      end
      
      diff_method = "_diff_#{data[:common_type]}"
      if data[:common_type] && respond_to?(diff_method, true)
        equal, breakdown = __send__(diff_method, args[:expected], args[:actual])
      else
        equal = (args[:expected] == args[:actual])
      end
      
      if args[:expected] && args[:actual]
        data[:state] = (equal ? :equal : :inequal)
      elsif args[:expected]
        data[:state] = :missing
      elsif args[:actual]
        data[:state] = :surplus
      end
      data[:breakdown] = breakdown if breakdown
      data
    end
  
    def _diff_array(expected, actual)
      equal = true
      breakdown = []
      (0...expected.size).each do |i|
        if i > actual.size - 1
          subdata = _diff(:expected => expected[i])
          equal = false
        else
          subdata = _diff(:expected => expected[i], :actual => actual[i])
          equal &&= (subdata[:state] == :equal)
        end
        breakdown << [i, subdata]
      end
      if actual.size > expected.size
        equal = false
        (expected.size .. actual.size-1).each do |i|
          subdata = _diff(:actual => actual[i])
          breakdown << [i, subdata]
        end
      end
      [equal, breakdown]
    end
    
    def _diff_hash(expected, actual)
      equal = true
      breakdown = []
      expected.keys.each do |k|
        if actual.include?(k)
          subdata = _diff(:expected => expected[k], :actual => actual[k])
          equal &&= (subdata[:state] == :equal)
        else
          subdata = _diff(:expected => expected[k])
          equal = false
        end
        breakdown << [k, subdata]
      end
      (actual.keys - expected.keys).each do |k|
        equal = false
        subdata = _diff(:actual => actual[k])
        breakdown << [k, subdata]
      end
      [equal, breakdown]
    end
    
    def type_of(value)
      case value
        when Fixnum then :number
        else value.class.to_s.downcase.to_sym
      end
    end
    
    def value_data_for(value)
      data = {:value => value, :type => type_of(value)}
      data[:size] = value.size if value.is_a?(Enumerable)
      data
    end
  end
end