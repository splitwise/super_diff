require File.expand_path('../test_helper', __FILE__)

module SuperDiff
  class DifferTest < TestCase
    def setup
      @differ = SuperDiff::Differ.new
    end
    
    def test_differing_strings
      actual = @differ.diff("foo", "bar")
      expected = {
        :expected => {:value => "foo", :class => String},
        :actual => {:value => "bar", :class => String},
        :same_class => true
      }
      assert_equal expected, actual
    end
  end
end