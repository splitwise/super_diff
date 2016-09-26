module SuperDiff
  class Differ
    def self.diff(old_element, new_element)
      new(old_element, new_element).diff
    end

    def initialize(old_element, new_element)
      @old_element = old_element
      @new_element = new_element
    end

    def diff
      _diff(:old_element => @old_element, :new_element => @new_element)
    end

  private
    def _diff(args)
      data = {:old_element => nil, :new_element => nil, :common_type => nil}
      data[:old_element] = value_data_for(args[:old_element]) if args[:old_element]
      data[:new_element] = value_data_for(args[:new_element]) if args[:new_element]
      if data[:old_element] && data[:new_element] && data[:old_element][:type] == data[:new_element][:type]
        data[:common_type] = data[:old_element][:type]
      end

      diff_method = "_diff_#{data[:common_type]}"
      if data[:common_type] && respond_to?(diff_method, true)
        equal, details = __send__(diff_method, args[:old_element], args[:new_element])
      else
        equal = (args[:old_element] == args[:new_element])
      end

      if args[:old_element] && args[:new_element]
        data[:state] = (equal ? :equal : :inequal)
      elsif args[:old_element]
        data[:state] = :missing
      elsif args[:new_element]
        data[:state] = :surplus
      end
      data[:details] = details if details
      data
    end

    def _diff_array(old_element, new_element)
      equal = true
      details = []
      (0...old_element.size).each do |i|
        if i > new_element.size - 1
          subdata = _diff(:old_element => old_element[i])
          equal = false
        else
          subdata = _diff(:old_element => old_element[i], :new_element => new_element[i])
          equal &&= (subdata[:state] == :equal)
        end
        details << [i, subdata]
      end
      if new_element.size > old_element.size
        equal = false
        (old_element.size .. new_element.size-1).each do |i|
          subdata = _diff(:new_element => new_element[i])
          details << [i, subdata]
        end
      end
      [equal, details]
    end

    def _diff_hash(old_element, new_element)
      equal = true
      details = []
      old_element.keys.each do |k|
        if new_element.include?(k)
          subdata = _diff(:old_element => old_element[k], :new_element => new_element[k])
          equal &&= (subdata[:state] == :equal)
        else
          subdata = _diff(:old_element => old_element[k])
          equal = false
        end
        details << [k, subdata]
      end
      (new_element.keys - old_element.keys).each do |k|
        equal = false
        subdata = _diff(:new_element => new_element[k])
        details << [k, subdata]
      end
      [equal, details]
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
