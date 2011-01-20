require File.expand_path('../test_helper', __FILE__)

describe SuperDiff::Differ do
  before do
    @differ = SuperDiff::Differ.new
  end
  
  test "same strings" do
    actual = @differ.diff("foo", "foo")
    expected = {
      :equal => true,
      :expected => {:value => "foo", :type => :string},
      :actual => {:value => "bar", :type => :string},
      :same_class => true
    }
    actual.must_equal expected
  end
  
  test "differing strings" do
    actual = @differ.diff("foo", "bar")
    expected = {
      :equal => false,
      :expected => {:value => "foo", :type => :string},
      :actual => {:value => "bar", :type => :string},
      :same_class => true
    }
    actual.must_equal expected
  end
  
  test "differing numbers" do
    actual = @differ.diff(1, 1)
    expected = {
      :equal => true,
      :expected => {:value => 1, :type => :number},
      :actual => {:value => 2, :type => :number},
      :same_class => true
    }
    actual.must_equal expected
  end
  
  test "differing numbers" do
    actual = @differ.diff(1, 2)
    expected = {
      :equal => false,
      :expected => {:value => 1, :type => :number},
      :actual => {:value => 2, :type => :number},
      :same_class => true
    }
    actual.must_equal expected
  end
end