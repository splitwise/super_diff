require 'pp'

module SuperDiff
  class Differ
    def initialize(stdout)
      @stdout = stdout
    end
  
    def diff(expected, actual, level=0, prefix="*", root=true)
      if level == 0 && root
        $stdout.puts
        pp :expected => expected, :actual => actual
        $stdout.puts
      end
      formatted_prefix = format_prefix(prefix, level, root)
      if expected != actual
        same_klass = (expected.class == actual.class)
        klass = expected.class
        if same_klass
          if klass == Array
            if expected.size == actual.size
              puts "#{formatted_prefix}: Arrays of same size but with differing elements."
            else
              min_size = [expected.size, actual.size].min
              common_keys_are_equal = (expected[0..min_size-1] == actual[0..min_size-1])
              if common_keys_are_equal
                puts "#{formatted_prefix}: Arrays of differing size (no differing elements)."
              else
                puts "#{formatted_prefix}: Arrays of differing size and elements."
              end
            end
          elsif klass == Hash
            if expected.size == actual.size
              puts "#{formatted_prefix}: Hashes of same size but with differing elements."
            else
              common_keys = expected.keys & actual.keys
              common_keys_are_equal = expected.values_at(*common_keys) == actual.values_at(*common_keys)
              if common_keys_are_equal
                puts "#{formatted_prefix}: Hashes of differing size (no differing elements)."
              else
                puts "#{formatted_prefix}: Hashes of differing size and elements."
              end
            end
          else
            downcased_klass = klass.to_s.downcase
            downcased_klass = "number" if downcased_klass == "fixnum"
            puts "#{formatted_prefix}: Differing #{downcased_klass}s."
          end
        else
          puts "#{formatted_prefix}: Values of differing type."
        end
        puts if level == 0 && root
        if (level == 0 && root) || !same_klass || ![Array, Hash].include?(klass)
          maybe_bullet = (level == 0 && root) ? "" : indented_bullet(level + 1)
          puts "#{maybe_bullet}Expected: #{expected.inspect}"
          puts "#{maybe_bullet}Got: #{actual.inspect}"
        end
        if (level == 0 && root) && same_klass && [Array, Hash].include?(klass)
          puts
          puts "Breakdown:"
        end
        if same_klass
          diff_array(expected, actual, level, prefix, root) if klass == Array
          diff_hash(expected, actual, level, prefix, root) if klass == Hash
        end
      end
    end
  
  private
    def diff_array(expected, actual, level, prefix, root)
      new_level = (level == 0 && root ? level : level+1)      
      (0...expected.size).each do |i|
        new_prefix = "*[#{i}]"
        formatted_prefix = format_prefix(new_prefix, new_level, false)
        if i > actual.size - 1
          puts "#{formatted_prefix}: Expected to have been found, but missing (value: #{expected[i].inspect})."
        else
          diff(expected[i], actual[i], new_level, new_prefix, false)
        end
      end
      if actual.size > expected.size
        (expected.size .. actual.size-1).each do |i|
          new_prefix = "*[#{i}]"
          formatted_prefix = format_prefix(new_prefix, new_level, false)
          puts "#{formatted_prefix}: Expected to not be present, but found (value: #{actual[i].inspect})."
        end
      end
    end
    
    def diff_hash(expected, actual, level, prefix, root)
      new_level = (level == 0 && root ? level : level+1)
      expected.keys.each do |k|
        new_prefix = "*[#{k.inspect}]"
        formatted_prefix = format_prefix(new_prefix, new_level, false)
        if actual.include?(k)
          diff(expected[k], actual[k], new_level, new_prefix, false)
        else
          puts "#{formatted_prefix}: Expected to have been found, but missing (value: #{expected[k].inspect})."
        end
      end
      (actual.keys - expected.keys).each do |k|
        new_prefix = "*[#{k.inspect}]"
        formatted_prefix = format_prefix(new_prefix, new_level, false)
        puts "#{formatted_prefix}: Expected to not be present, but found (value: #{actual[k].inspect})."
      end
    end
  
    def indented_bullet(level)
      (" " * (level * 2)) + "- "
    end
  
    def format_prefix(prefix, level, root)
      (level == 0 && root) ? "Error" : indented_bullet(level) + prefix
    end
    
    def puts(*args)
      $stdout.puts(*args)
      @stdout.puts(*args)
    end
  end
end