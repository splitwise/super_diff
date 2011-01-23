module SuperDiff
  class Reporter
    def initialize(stdout)
      @stdout = stdout
    end
  
    def report(data)
      _report(data, 0, "*", true)
    end
    
  private
    def _report(data, level, prefix, root)
      return if data[:state] == :equal
      
      formatted_prefix = format_prefix(prefix, level, root)
      
      case data[:common_type]
      when nil
        case data[:state]
        when :surplus
          puts "#{formatted_prefix}: Expected to not be present, but found #{data[:actual][:value].inspect}."
        when :missing
          puts "#{formatted_prefix}: Expected to have been found, but missing #{data[:expected][:value].inspect}."
        when :inequal
          puts "#{formatted_prefix}: Values of differing type."
        end
      when :array, :hash
        plural_type = pluralize(data[:common_type]).capitalize
        if data[:expected][:size] == data[:actual][:size]
          puts "#{formatted_prefix}: #{plural_type} of same size but with differing elements."
        elsif data[:breakdown].none? {|k, subdata| subdata[:state] == :inequal }
          puts "#{formatted_prefix}: #{plural_type} of differing size (no differing elements)."
        else
          puts "#{formatted_prefix}: #{plural_type} of differing size and elements."
        end
      else
        plural_type = pluralize(data[:common_type])
        puts "#{formatted_prefix}: Differing #{plural_type}."
      end
      puts if root
      if data[:state] == :inequal && (root || !data[:common_type] || !data[:breakdown])
        maybe_bullet = root ? "" : indented_bullet(level + 1)
        puts "#{maybe_bullet}Expected: #{data[:expected][:value].inspect}"
        puts "#{maybe_bullet}Got: #{data[:actual][:value].inspect}"
      end
      if data[:breakdown]
        if root
          puts
          puts "Breakdown:"
        end
        _report_breakdown(data[:breakdown], level, prefix, root)
      end
    end
  
    def _report_breakdown(breakdown, level, prefix, root)
      new_level = root ? level : level+1
      breakdown.each do |(key, subdata)|
        new_prefix = "*[#{key.inspect}]"
        formatted_prefix = format_prefix(new_prefix, new_level, false)
        _report(subdata, new_level, new_prefix, false)
      end
    end
  
    def indented_bullet(level)
      (" " * (level * 2)) + "- "
    end
  
    def format_prefix(prefix, level, root)
      (level == 0 && root) ? "Error" : indented_bullet(level) + prefix
    end
    
    def pluralize(word)
      word = word.to_s
      word == "hash" ? "hashes" : "#{word}s"
    end
    
    def puts(*args)
      $stdout.puts(*args)
      @stdout.puts(*args)
    end
  end
end