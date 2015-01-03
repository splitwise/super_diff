require 'spec_helper'
require 'super_diff/recursive_differ'

describe SuperDiff::RecursiveDiffer do
  describe '#diff' do
    it "returns what would normally be returned for shallow arrays" do
      seq1 = %w(a b c d e f g)
      seq2 = %w(1 2 a b e f g h i)
      SuperDiff::RecursiveDiffer.diff(seq1, seq2).should == [
        SuperDiff::RecursiveDiffer::Event.new("+", 0, nil, 0, "1"),
        SuperDiff::RecursiveDiffer::Event.new("+", 0, nil, 1, "2"),
        SuperDiff::RecursiveDiffer::Event.new("=", 0, "a", 2, "a"),
        SuperDiff::RecursiveDiffer::Event.new("=", 1, "b", 3, "b"),
        SuperDiff::RecursiveDiffer::Event.new("-", 2, "c", 4, nil),
        SuperDiff::RecursiveDiffer::Event.new("-", 3, "d", 4, nil),
        SuperDiff::RecursiveDiffer::Event.new("=", 4, "e", 4, "e"),
        SuperDiff::RecursiveDiffer::Event.new("=", 5, "f", 5, "f"),
        SuperDiff::RecursiveDiffer::Event.new("=", 6, "g", 6, "g"),
        SuperDiff::RecursiveDiffer::Event.new("+", 7, nil, 7, "h"),
        SuperDiff::RecursiveDiffer::Event.new("+", 7, nil, 8, "i")
      ]
    end

    it "performs the LCS on arrays within arrays" do
      seq1 = [ %w(a b c d e f g) ]
      seq2 = [ %w(1 2 a b e f g h i) ]
      SuperDiff::RecursiveDiffer.diff(seq1, seq2).should == [
        SuperDiff::RecursiveDiffer::Event.new("!", 0, %w(a b c d e f g), 0, %w(1 2 a b e f g h i), [
          SuperDiff::RecursiveDiffer::Event.new("+", 0, nil, 0, "1"),
          SuperDiff::RecursiveDiffer::Event.new("+", 0, nil, 1, "2"),
          SuperDiff::RecursiveDiffer::Event.new("=", 0, "a", 2, "a"),
          SuperDiff::RecursiveDiffer::Event.new("=", 1, "b", 3, "b"),
          SuperDiff::RecursiveDiffer::Event.new("-", 2, "c", 4, nil),
          SuperDiff::RecursiveDiffer::Event.new("-", 3, "d", 4, nil),
          SuperDiff::RecursiveDiffer::Event.new("=", 4, "e", 4, "e"),
          SuperDiff::RecursiveDiffer::Event.new("=", 5, "f", 5, "f"),
          SuperDiff::RecursiveDiffer::Event.new("=", 6, "g", 6, "g"),
          SuperDiff::RecursiveDiffer::Event.new("+", 7, nil, 7, "h"),
          SuperDiff::RecursiveDiffer::Event.new("+", 7, nil, 8, "i")
        ])
      ]
    end

    it "ignores hashes within arrays" do
      seq1 = [ {:foo => "bar"} ]
      seq2 = [ {:foo => "baz"} ]
      SuperDiff::RecursiveDiffer.diff(seq1, seq2).should == [
        SuperDiff::RecursiveDiffer::Event.new("!", 0, {:foo => "bar"}, 0, {:foo => "baz"}, [])
      ]
    end
  end
end
