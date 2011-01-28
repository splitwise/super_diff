module SuperDiff
  class Reporter
    def initialize(stdout)
      @stdout = stdout
    end

    def report(data, options={})
      _report(data, options.merge(:level => 0, :prefix => "*", :root => true))
    end

  private
    def _report(data, args)
      return if data[:state] == :equal

      if !args[:root] && args[:collapsed] && data[:breakdown]
        _report_breakdown(data[:breakdown], args)
        return
      end

      formatted_prefix = format_prefix(args)

      case data[:common_type]
      when nil
        case data[:state]
        when :surplus
          puts "#{formatted_prefix}: Expected to not be present, but found #{data[:new_element][:value].inspect}."
        when :missing
          puts "#{formatted_prefix}: Expected to have been found, but missing #{data[:old_element][:value].inspect}."
        when :inequal
          puts "#{formatted_prefix}: Values of differing type."
        end
      when :array, :hash
        plural_type = pluralize(data[:common_type]).capitalize
        if data[:old_element][:size] == data[:new_element][:size]
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
      puts if args[:root]
      if data[:state] == :inequal && (args[:root] || !data[:common_type] || !data[:breakdown])
        maybe_bullet = args[:root] ? "" : indented_bullet(args[:level] + 1)
        puts "#{maybe_bullet}Expected: #{data[:old_element][:value].inspect}"
        puts "#{maybe_bullet}Got: #{data[:new_element][:value].inspect}"
      end
      if data[:breakdown]
        if args[:root]
          puts
          puts "Breakdown:"
        end
        new_level = args[:root] ? args[:level] : args[:level]+1
        _report_breakdown(data[:breakdown], args.merge(:level => new_level))
      end
    end

    def _report_breakdown(breakdown, args)
      breakdown.each do |(key, subdata)|
        new_prefix = args[:collapsed] ? "#{args[:prefix]}[#{key.inspect}]" : "*[#{key.inspect}]"
        new_args = args.merge(:prefix => new_prefix, :root => false)
        _report(subdata, new_args)
      end
    end

    def indented_bullet(level)
      (" " * (level * 2)) + "- "
    end

    def format_prefix(args)
      args[:root] ? "Error" : indented_bullet(args[:level]) + args[:prefix]
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