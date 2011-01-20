require File.expand_path('../test_helper', __FILE__)

module SuperDiff
  class DifferTest < TestCase
    def setup
      @differ = SuperDiff::Differ.new
    end
    
    def test_same_strings
      actual = @differ.diff("foo", "foo")
      expected = {
        :equal => true,
        :expected => {:value => "foo", :type => :string},
        :actual => {:value => "bar", :type => :string},
        :same_class => true
      }
      assert_equal expected, actual
    end
    
    def test_differing_strings
      actual = @differ.diff("foo", "bar")
      expected = {
        :equal => false,
        :expected => {:value => "foo", :type => :string},
        :actual => {:value => "bar", :type => :string},
        :same_class => true
      }
      assert_equal expected, actual
    end
    
    def test_differing_numbers
      actual = @differ.diff(1, 1)
      expected = {
        :equal => true,
        :expected => {:value => 1, :type => :number},
        :actual => {:value => 2, :type => :number},
        :same_class => true
      }
      assert_equal expected, actual
    end
    
    def test_differing_numbers
      actual = @differ.diff(1, 2)
      expected = {
        :equal => false,
        :expected => {:value => 1, :type => :number},
        :actual => {:value => 2, :type => :number},
        :same_class => true
      }
      assert_equal expected, actual
    end
  end
end