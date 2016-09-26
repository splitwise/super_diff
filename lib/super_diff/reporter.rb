module SuperDiff
  class Reporter
    def self.report(change, **options)
      output = options.delete(:to)
      new(change, output, options).report
    end

    def initialize(change, output, options)
      @change = change
      @output = output
      @options = options
    end

    def report
      report_change(
        @change,
        @options.merge(level: 0, prefix: "*", root: true)
      )
    end

  private
    def report_change(change, args)
      return if change[:state] == :equal

      common_type = lambda {|x| x && x[:type] }.call(change[:elements][:common])

      if args[:root]
        formatted_prefix = "Error"
      else
        full_prefix = full_prefix(change[:elements][:old][:key], change[:elements][:new][:key], common_type, args)
        args[:prefix] = full_prefix if args[:collapsed]
        formatted_prefix = indented_bullet(args[:level]) + full_prefix
      end

      if !args[:root] && args[:collapsed] && change[:details]
        report_details(change[:details], change, args)
        return
      end

      if common_type == :array && count_as_replacement?(change)
        change = change.dup.merge(:details => nil)
      end

      if [:array, :hash].include?(common_type) && change[:details]
        plural_type = pluralize(common_type).capitalize
        if change[:elements][:common][:size]
          puts "#{formatted_prefix}: #{plural_type} of same size but with differing elements."
        elsif change[:details].none? {|hunk_type, hunk| hunk_type == :inequal }
          puts "#{formatted_prefix}: #{plural_type} of differing size (no differing elements)."
        else
          puts "#{formatted_prefix}: #{plural_type} of differing size and elements."
        end
      elsif common_type.nil?
        puts "#{formatted_prefix}: Values of differing type."
      else
        plural_type = pluralize(common_type)
        puts "#{formatted_prefix}: Differing #{plural_type}."
      end
      puts if args[:root]
      if change[:state] == :inequal && (args[:root] || !common_type || !change[:details])
        maybe_bullet = args[:root] ? "" : indented_bullet(args[:level] + 1)
        puts "#{maybe_bullet}Expected: #{change[:elements][:old][:value].inspect}"
        puts "#{maybe_bullet}Got: #{change[:elements][:new][:value].inspect}"
      end
      if change[:details]
        if args[:root]
          puts
          puts "Details:"
        end
        new_level = args[:root] ? args[:level] : args[:level]+1
        report_details(change[:details], change, args.merge(:level => new_level))
      end
    end

    def report_details(details, parent_change, args)
      details.each do |hunk_type, hunk|
        new_args = args.merge(:root => false)
        case hunk_type
        when :surplus
          report_surplus_hunk(hunk, parent_change, new_args)
        when :missing
          report_missing_hunk(hunk, parent_change, new_args)
        else
          report_change(hunk[0], new_args)
        end
      end
    end

    def report_surplus_hunk(hunk, parent_change, args)
      keys = hunk.map {|change| change[:elements][:new][:key] }
      parent_change_type = parent_change[:elements][:new][:type]

      full_prefix = full_prefix(
        nil,
        keys,
        parent_change_type,
        args
      )
      args[:prefix] = full_prefix if !args[:root] && args[:collapsed]
      formatted_prefix = indented_bullet(args[:level]) + full_prefix

      values = hunk.map {|change| change[:elements][:new][:value].inspect }.join(", ")
      parent_elements = parent_change[:elements]
      if parent_change_type == :array
        if keys.first == 0
          at_position = " before #{parent_elements[:new][:value][keys.last + 1].inspect}"
        elsif (
          # TODO: any better way to test for this?
          parent_elements[:old] and parent_elements[:old][:value] and
          old_value = parent_elements[:old][:value][keys.first - 1] and
          new_value = parent_elements[:new][:value][keys.first - 1] and
          old_value != new_value
        )
          at_position = " after #{old_value.inspect}"
          at_position << " (now #{new_value.inspect})"
        else
          at_position = " after #{parent_elements[:new][:value][keys.first - 1].inspect}"
        end
      end
      puts "#{formatted_prefix}: #{values} unexpectedly found#{at_position}."
    end

    def report_missing_hunk(hunk, parent_change, args)
      keys = hunk.map {|change| change[:elements][:old][:key] }
      parent_change_type = parent_change[:elements][:old][:type]

      full_prefix = full_prefix(
        keys,
        nil,
        parent_change_type,
        args
      )
      args[:prefix] = full_prefix if !args[:root] && args[:collapsed]
      formatted_prefix = indented_bullet(args[:level]) + full_prefix

      values = hunk.map {|change| change[:elements][:old][:value].inspect }.join(", ")
      parent_elements = parent_change[:elements]
      if parent_change_type == :array
        if keys.first == 0
          at_position = " from before #{parent_elements[:old][:value][keys.last + 1].inspect}"
        else
          old_value = parent_elements[:old][:value][keys.first - 1]
          at_position = " from after #{old_value.inspect}"
          if (
            # TODO: any better way to test for this?
            parent_elements[:new] and parent_elements[:new][:value] and
            new_value = parent_elements[:new][:value][keys.first - 1] and
            old_value != new_value
          )
            at_position << " (now #{new_value.inspect})"
          end
        end
      end
      puts "#{formatted_prefix}: #{values} unexpectedly missing#{at_position}."
    end

    def count_as_replacement?(change)
      return unless lambda {|x| x && x[:type] }.call(change[:elements][:common])

      # If we're diffing two arrays, and a "missing" hunk deletes all elements
      # in the array, and a "surplus" hunk exists, then merge the "missing" and
      # "surplus" hunks together and count them as a replacement
      missings, surpluses = [], []
      change[:details].each do |hunk_type, hunk|
        missings += hunk if hunk_type == :missing
        surpluses += hunk if hunk_type == :surplus
      end
      return (missings.size == change[:elements][:old][:size] && surpluses.size > 0)
    end

    def indented_bullet(level)
      (" " * (level * 2)) + "- "
    end

    def full_prefix(old_keys, new_keys, change_type, args)
      old_keys = [old_keys] unless old_keys.nil? or Array === old_keys
      new_keys = [new_keys] unless new_keys.nil? or Array === new_keys
      if old_keys == new_keys
        key_string = format_prefix_key(old_keys, change_type)
      else
        old_key_string = old_keys ? format_prefix_key(old_keys, change_type) : "?"
        new_key_string = new_keys ? format_prefix_key(new_keys, change_type) : "?"
        key_string = "#{old_key_string} -> #{new_key_string}"
      end
      args[:prefix] + "[#{key_string}]"
    end

    def format_prefix_key(keys, change_type)
      if keys.size == 1
        keys[0].inspect
      elsif change_type == :array
        (keys[0]..keys[-1]).inspect
      else
        keys.join(", ")
      end
    end

    def pluralize(word)
      word = word.to_s
      word == "hash" ? "hashes" : "#{word}s"
    end

    def puts(*args)
      $stdout.puts(*args)
      @output.puts(*args)
    end
  end
end
