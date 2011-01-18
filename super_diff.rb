require 'pp'

module SuperDiff
  class Reporter
    def initialize(stdout)
      @stdout = stdout
    end
  
    def puts(*args)
      $stdout.puts(*args)
      @stdout.puts(*args)
    end
  
    def indented_bullet(level)
      (" " * (level * 2)) + "- "
    end
  
    def format_prefix(prefix, level, root)
      (level == 0 && root) ? "Error" : indented_bullet(level) + prefix
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
              ##surplus_elements = actual - expected
              ##missing_elements = expected - actual
              # hmm... what we really want to know if there are any elements which
              # are in actual that are not in expected *assuming that the other
              # elements are equal*... and same for expected... that requires that
              # we go through the array first, though.
              puts "#{formatted_prefix}: Arrays of differing size and elements."
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
        if (level == 0 && root) || !same_klass || (klass == String || klass == Fixnum)
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
        end
      end
    end
  
    def diff_array(expected, actual, level, prefix, root)
      (0...expected.size).each do |i|
        diff(expected[i], actual[i], (level == 0 && root ? level : level+1), "*[#{i}]", false)
      end
    end
  end
end