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
      :actual => {:value => "foo", :type => :string}
    }
    actual.must_equal expected
  end
  
  test "differing strings" do
    actual = @differ.diff("foo", "bar")
    expected = {
      :equal => false,
      :expected => {:value => "foo", :type => :string},
      :actual => {:value => "bar", :type => :string}
    }
    actual.must_equal expected
  end
  
  test "same numbers" do
    actual = @differ.diff(1, 1)
    expected = {
      :equal => true,
      :expected => {:value => 1, :type => :number},
      :actual => {:value => 1, :type => :number}
    }
    actual.must_equal expected
  end
  
  test "differing numbers" do
    actual = @differ.diff(1, 2)
    expected = {
      :equal => false,
      :expected => {:value => 1, :type => :number},
      :actual => {:value => 2, :type => :number}
    }
    actual.must_equal expected
  end
  
  test "values of differing simple types" do
    actual = @differ.diff("foo", 1)
    expected = {
      :equal => false,
      :expected => {:value => "foo", :type => :string},
      :actual => {:value => 1, :type => :number}
    }
    actual.must_equal expected
  end
  
  test "values of differing complex types" do
    actual = @differ.diff("foo", %w(zing zang))
    expected = {
      :equal => false,
      :expected => {:value => "foo", :type => :string},
      :actual => {:value => %w(zing zang), :type => :array}
    }
    actual.must_equal expected
  end
  
  test "shallow arrays of same size but with differing elements" do
    actual = @differ.diff(["foo", "bar"], ["foo", "baz"])
    expected = {
      :equal => false,
      :expected => {:value => ["foo", "bar"], :type => :array},
      :actual => {:value => ["foo", "baz"], :type => :array},
      :breakdown => {
        '[0]' => {
          :equal => true,
          :expected => {:value => "foo", :type => :string},
          :actual => {:value => "foo", :type => :string}
        },
        '[1]' => {
          :equal => false,
          :expected => {:value => "bar", :type => :string},
          :actual => {:value => "baz", :type => :string}
        }
      }
    }
    actual.must_equal expected
  end
end