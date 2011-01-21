require File.expand_path('../spec_helper', __FILE__)

describe SuperDiff::Differ do
  before do
    @differ = SuperDiff::Differ.new
  end
  
  describe '#diff', 'generates correct data for' do
    specify "same strings" do
      actual = @differ.diff("foo", "foo")
      expected = {
        :equal => true,
        :expected => {:value => "foo", :type => :string},
        :actual => {:value => "foo", :type => :string}
      }
      actual.must == expected
    end
  
    specify "differing strings" do
      actual = @differ.diff("foo", "bar")
      expected = {
        :equal => false,
        :expected => {:value => "foo", :type => :string},
        :actual => {:value => "bar", :type => :string}
      }
      actual.must == expected
    end
  
    specify "same numbers" do
      actual = @differ.diff(1, 1)
      expected = {
        :equal => true,
        :expected => {:value => 1, :type => :number},
        :actual => {:value => 1, :type => :number}
      }
      actual.must == expected
    end
  
    specify "differing numbers" do
      actual = @differ.diff(1, 2)
      expected = {
        :equal => false,
        :expected => {:value => 1, :type => :number},
        :actual => {:value => 2, :type => :number}
      }
      actual.must == expected
    end
  
    specify "values of differing simple types" do
      actual = @differ.diff("foo", 1)
      expected = {
        :equal => false,
        :expected => {:value => "foo", :type => :string},
        :actual => {:value => 1, :type => :number}
      }
      actual.must == expected
    end
  
    specify "values of differing complex types" do
      actual = @differ.diff("foo", %w(zing zang))
      expected = {
        :equal => false,
        :expected => {:value => "foo", :type => :string},
        :actual => {:value => %w(zing zang), :type => :array}
      }
      actual.must == expected
    end
  
    specify "shallow arrays of same size but with differing elements" do
      actual = @differ.diff(["foo", "bar"], ["foo", "baz"])
      expected = {
        :equal => false,
        :expected => {:value => ["foo", "bar"], :type => :array},
        :actual => {:value => ["foo", "baz"], :type => :array},
        :breakdown => [
          [0, {
            :equal => true,
            :expected => {:value => "foo", :type => :string},
            :actual => {:value => "foo", :type => :string}
          }],
          [1, {
            :equal => false,
            :expected => {:value => "bar", :type => :string},
            :actual => {:value => "baz", :type => :string}
          }]
        ]
      }
      actual.must == expected
    end
  
    specify "deep arrays of same size but with differing elements" do
      actual = @differ.diff(
        [["foo", "bar"], ["baz", "quux"]],
        [["foo", "biz"], ["baz", "quarks"]]
      )
      expected = {
        :equal => false,
        :expected => {:value => [["foo", "bar"], ["baz", "quux"]], :type => :array},
        :actual => {:value => [["foo", "biz"], ["baz", "quarks"]], :type => :array},
        :breakdown => [
          [0, {
            :equal => false,
            :expected => {:value => ["foo", "bar"], :type => :array},
            :actual => {:value => ["foo", "biz"], :type => :array},
            :breakdown => [
              [0, {
                :equal => true,
                :expected => {:value => "foo", :type => :string},
                :actual => {:value => "foo", :type => :string}
              }],
              [1, {
                :equal => false,
                :expected => {:value => "bar", :type => :string},
                :actual => {:value => "biz", :type => :string}
              }]
            ]
          }],
          [1, {
            :equal => false,
            :expected => {:value => ["baz", "quux"], :type => :array},
            :actual => {:value => ["baz", "quarks"], :type => :array},
            :breakdown => [
              [0, {
                :equal => true,
                :expected => {:value => "baz", :type => :string},
                :actual => {:value => "baz", :type => :string}
              }],
              [1, {
                :equal => false,
                :expected => {:value => "quux", :type => :string},
                :actual => {:value => "quarks", :type => :string}
              }]
            ]
          }]
        ]
      }
      actual.must == expected
    end
    
    specify "deeper arrays with differing elements" do
      actual = @differ.diff(
        [
          "foo",
          ["bar", ["baz", "quux"]],
          "ying",
          ["blargh", "zing", "fooz", ["raz", ["vermouth"]]]
        ],
        [
          "foz",
          "bar",
          "ying",
          ["blargh", "gragh", 1, ["raz", ["ralston"]]]
        ]
      )
      expected = {
        :equal => false,
        :expected => {
          :value => [
            "foo",
            ["bar", ["baz", "quux"]],
            "ying",
            ["blargh", "zing", "fooz", ["raz", ["vermouth"]]]
          ],
          :type => :array
        },
        :actual => {
          :value => [
            "foz",
            "bar",
            "ying",
            ["blargh", "gragh", 1, ["raz", ["ralston"]]]
          ],
          :type => :array
        },
        :breakdown => [
          [0, {
            :equal => false,
            :expected => {:value => "foo", :type => :string},
            :actual => {:value => "foz", :type => :string}
          }],
          [1, {
            :equal => false,
            :expected => {:value => ["bar", ["baz", "quux"]], :type => :array},
            :actual => {:value => "bar", :type => :string}
          }],
          [2, {
            :equal => true,
            :expected => {:value => "ying", :type => :string},
            :actual => {:value => "ying", :type => :string}
          }],
          [3, {
            :equal => false,
            :expected => {
              :value => ["blargh", "zing", "fooz", ["raz", ["vermouth"]]],
              :type => :array
            },
            :actual => {
              :value => ["blargh", "gragh", 1, ["raz", ["ralston"]]],
              :type => :array
            },
            :breakdown => [
              [0, {
                :equal => true,
                :expected => {:value => "blargh", :type => :string},
                :actual => {:value => "blargh", :type => :string}
              }],
              [1, {
                :equal => false,
                :expected => {:value => "zing", :type => :string},
                :actual => {:value => "gragh", :type => :string}
              }],
              [2, {
                :equal => false,
                :expected => {:value => "fooz", :type => :string},
                :actual => {:value => 1, :type => :number}
              }],
              [3, {
                :equal => false,
                :expected => {:value => ["raz", ["vermouth"]], :type => :array},
                :actual => {:value => ["raz", ["ralston"]], :type => :array},
                :breakdown => [
                  [0, {
                    :equal => true,
                    :expected => {:value => "raz", :type => :string},
                    :actual => {:value => "raz", :type => :string}
                  }],
                  [1, {
                    :equal => false,
                    :expected => {:value => ["vermouth"], :type => :array},
                    :actual => {:value => ["ralston"], :type => :array},
                    :breakdown => [
                      [0, {
                        :equal => false,
                        :expected => {:value => "vermouth", :type => :string},
                        :actual => {:value => "ralston", :type => :string}
                      }]
                    ]
                  }]
                ]
              }]
            ]
          }]
        ]
      }
      actual.must == expected
    end
  end
end