require File.expand_path('../spec_helper', __FILE__)

describe SuperDiff::Differ do
  before do
    @differ = SuperDiff::Differ.new
  end
  
  describe '#diff', 'generates correct data for' do
    specify "same strings" do
      actual = @differ.diff("foo", "foo")
      expected = {
        :state => :equal,
        :expected => {:value => "foo", :type => :string},
        :actual => {:value => "foo", :type => :string},
        :common_type => :string
      }
      actual.must == expected
    end
  
    specify "differing strings" do
      actual = @differ.diff("foo", "bar")
      expected = {
        :state => :inequal,
        :expected => {:value => "foo", :type => :string},
        :actual => {:value => "bar", :type => :string},
        :common_type => :string
      }
      actual.must == expected
    end
  
    specify "same numbers" do
      actual = @differ.diff(1, 1)
      expected = {
        :state => :equal,
        :expected => {:value => 1, :type => :number},
        :actual => {:value => 1, :type => :number},
        :common_type => :number
      }
      actual.must == expected
    end
  
    specify "differing numbers" do
      actual = @differ.diff(1, 2)
      expected = {
        :state => :inequal,
        :expected => {:value => 1, :type => :number},
        :actual => {:value => 2, :type => :number},
        :common_type => :number
      }
      actual.must == expected
    end
  
    specify "values of differing simple types" do
      actual = @differ.diff("foo", 1)
      expected = {
        :state => :inequal,
        :expected => {:value => "foo", :type => :string},
        :actual => {:value => 1, :type => :number},
        :common_type => nil
      }
      actual.must == expected
    end
  
    specify "values of differing complex types" do
      actual = @differ.diff("foo", %w(zing zang))
      expected = {
        :state => :inequal,
        :expected => {:value => "foo", :type => :string},
        :actual => {:value => %w(zing zang), :type => :array},
        :common_type => nil
      }
      actual.must == expected
    end
  
    specify "shallow arrays of same size but with differing elements" do
      actual = @differ.diff(["foo", "bar"], ["foo", "baz"])
      expected = {
        :state => :inequal,
        :expected => {:value => ["foo", "bar"], :type => :array},
        :actual => {:value => ["foo", "baz"], :type => :array},
        :common_type => :array,
        :breakdown => [
          [0, {
            :state => :equal,
            :expected => {:value => "foo", :type => :string},
            :actual => {:value => "foo", :type => :string},
            :common_type => :string
          }],
          [1, {
            :state => :inequal,
            :expected => {:value => "bar", :type => :string},
            :actual => {:value => "baz", :type => :string},
            :common_type => :string
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
        :state => :inequal,
        :expected => {:value => [["foo", "bar"], ["baz", "quux"]], :type => :array},
        :actual => {:value => [["foo", "biz"], ["baz", "quarks"]], :type => :array},
        :common_type => :array,
        :breakdown => [
          [0, {
            :state => :inequal,
            :expected => {:value => ["foo", "bar"], :type => :array},
            :actual => {:value => ["foo", "biz"], :type => :array},
            :common_type => :array,
            :breakdown => [
              [0, {
                :state => :equal,
                :expected => {:value => "foo", :type => :string},
                :actual => {:value => "foo", :type => :string},
                :common_type => :string
              }],
              [1, {
                :state => :inequal,
                :expected => {:value => "bar", :type => :string},
                :actual => {:value => "biz", :type => :string},
                :common_type => :string
              }]
            ]
          }],
          [1, {
            :state => :inequal,
            :expected => {:value => ["baz", "quux"], :type => :array},
            :actual => {:value => ["baz", "quarks"], :type => :array},
            :common_type => :array,
            :breakdown => [
              [0, {
                :state => :equal,
                :expected => {:value => "baz", :type => :string},
                :actual => {:value => "baz", :type => :string},
                :common_type => :string
              }],
              [1, {
                :state => :inequal,
                :expected => {:value => "quux", :type => :string},
                :actual => {:value => "quarks", :type => :string},
                :common_type => :string
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
        :state => :inequal,
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
        :common_type => :array,
        :breakdown => [
          [0, {
            :state => :inequal,
            :expected => {:value => "foo", :type => :string},
            :actual => {:value => "foz", :type => :string},
            :common_type => :string
          }],
          [1, {
            :state => :inequal,
            :expected => {:value => ["bar", ["baz", "quux"]], :type => :array},
            :actual => {:value => "bar", :type => :string},
            :common_type => nil
          }],
          [2, {
            :state => :equal,
            :expected => {:value => "ying", :type => :string},
            :actual => {:value => "ying", :type => :string},
            :common_type => :string
          }],
          [3, {
            :state => :inequal,
            :expected => {
              :value => ["blargh", "zing", "fooz", ["raz", ["vermouth"]]],
              :type => :array
            },
            :actual => {
              :value => ["blargh", "gragh", 1, ["raz", ["ralston"]]],
              :type => :array
            },
            :common_type => :array,
            :breakdown => [
              [0, {
                :state => :equal,
                :expected => {:value => "blargh", :type => :string},
                :actual => {:value => "blargh", :type => :string},
                :common_type => :string
              }],
              [1, {
                :state => :inequal,
                :expected => {:value => "zing", :type => :string},
                :actual => {:value => "gragh", :type => :string},
                :common_type => :string
              }],
              [2, {
                :state => :inequal,
                :expected => {:value => "fooz", :type => :string},
                :actual => {:value => 1, :type => :number},
                :common_type => nil
              }],
              [3, {
                :state => :inequal,
                :expected => {:value => ["raz", ["vermouth"]], :type => :array},
                :actual => {:value => ["raz", ["ralston"]], :type => :array},
                :common_type => :array,
                :breakdown => [
                  [0, {
                    :state => :equal,
                    :expected => {:value => "raz", :type => :string},
                    :actual => {:value => "raz", :type => :string},
                    :common_type => :string
                  }],
                  [1, {
                    :state => :inequal,
                    :expected => {:value => ["vermouth"], :type => :array},
                    :actual => {:value => ["ralston"], :type => :array},
                    :common_type => :array,
                    :breakdown => [
                      [0, {
                        :state => :inequal,
                        :expected => {:value => "vermouth", :type => :string},
                        :actual => {:value => "ralston", :type => :string},
                        :common_type => :string
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
    
    specify "shallow arrays with surplus elements" do
      actual = @differ.diff(["foo", "bar"], ["foo", "bar", "baz", "quux"])
      expected = {
        :state => :inequal,
        :expected => {:value => ["foo", "bar"], :type => :array},
        :actual => {:value => ["foo", "bar", "baz", "quux"], :type => :array},
        :common_type => :array,
        :breakdown => [
          [0, {
            :state => :equal,
            :expected => {:value => "foo", :type => :string},
            :actual => {:value => "foo", :type => :string},
            :common_type => :string
          }],
          [1, {
            :state => :equal,
            :expected => {:value => "bar", :type => :string},
            :actual => {:value => "bar", :type => :string},
            :common_type => :string
          }],
          [2, {
            :state => :surplus,
            :expected => nil,
            :actual => {:value => "baz", :type => :string},
            :common_type => nil
          }],
          [3, {
            :state => :surplus,
            :expected => nil,
            :actual => {:value => "quux", :type => :string},
            :common_type => nil
          }]
        ]
      }
      actual.must == expected
    end
    
    specify "shallow arrays with missing elements" do
      actual = @differ.diff(["foo", "bar", "baz", "quux"], ["foo", "bar"])
      expected = {
        :state => :inequal,
        :expected => {:value => ["foo", "bar", "baz", "quux"], :type => :array},
        :actual => {:value => ["foo", "bar"], :type => :array},
        :common_type => :array,
        :breakdown => [
          [0, {
            :state => :equal,
            :expected => {:value => "foo", :type => :string},
            :actual => {:value => "foo", :type => :string},
            :common_type => :string
          }],
          [1, {
            :state => :equal,
            :expected => {:value => "bar", :type => :string},
            :actual => {:value => "bar", :type => :string},
            :common_type => :string
          }],
          [2, {
            :state => :missing,
            :expected => {:value => "baz", :type => :string},
            :actual => nil,
            :common_type => nil
          }],
          [3, {
            :state => :missing,
            :expected => {:value => "quux", :type => :string},
            :actual => nil,
            :common_type => nil
          }]
        ]
      }
      actual.must == expected
    end
    
    specify "deep arrays with surplus elements" do
      actual = @differ.diff(
        ["foo", ["bar", "baz"], "ying"],
        ["foo", ["bar", "baz", "quux", "blargh"], "ying"]
      )
      expected = {
        :state => :inequal,
        :expected => {:value => ["foo", ["bar", "baz"], "ying"], :type => :array},
        :actual => {:value => ["foo", ["bar", "baz", "quux", "blargh"], "ying"], :type => :array},
        :common_type => :array,
        :breakdown => [
          [0, {
            :state => :equal,
            :expected => {:value => "foo", :type => :string},
            :actual => {:value => "foo", :type => :string},
            :common_type => :string
          }],
          [1, {
            :state => :inequal,
            :expected => {:value => ["bar", "baz"], :type => :array},
            :actual => {:value => ["bar", "baz", "quux", "blargh"], :type => :array},
            :common_type => :array,
            :breakdown => [
              [0, {
                :state => :equal,
                :expected => {:value => "bar", :type => :string},
                :actual => {:value => "bar", :type => :string},
                :common_type => :string
              }],
              [1, {
                :state => :equal,
                :expected => {:value => "baz", :type => :string},
                :actual => {:value => "baz", :type => :string},
                :common_type => :string
              }],
              [2, {
                :state => :surplus,
                :expected => nil,
                :actual => {:value => "quux", :type => :string},
                :common_type => nil
              }],
              [3, {
                :state => :surplus,
                :expected => nil,
                :actual => {:value => "blargh", :type => :string},
                :common_type => nil
              }]
            ]
          }],
          [2, {
            :state => :equal,
            :expected => {:value => "ying", :type => :string},
            :actual => {:value => "ying", :type => :string},
            :common_type => :string
          }]
        ]
      }
      actual.must == expected
    end
    
    specify "deep arrays with missing elements" do
      actual = @differ.diff(
        ["foo", ["bar", "baz", "quux", "blargh"], "ying"],
        ["foo", ["bar", "baz"], "ying"]
      )
      expected = {
        :state => :inequal,
        :expected => {:value => ["foo", ["bar", "baz", "quux", "blargh"], "ying"], :type => :array},
        :actual => {:value => ["foo", ["bar", "baz"], "ying"], :type => :array},
        :common_type => :array,
        :breakdown => [
          [0, {
            :state => :equal,
            :expected => {:value => "foo", :type => :string},
            :actual => {:value => "foo", :type => :string},
            :common_type => :string
          }],
          [1, {
            :state => :inequal,
            :expected => {:value => ["bar", "baz", "quux", "blargh"], :type => :array},
            :actual => {:value => ["bar", "baz"], :type => :array},
            :common_type => :array,
            :breakdown => [
              [0, {
                :state => :equal,
                :expected => {:value => "bar", :type => :string},
                :actual => {:value => "bar", :type => :string},
                :common_type => :string
              }],
              [1, {
                :state => :equal,
                :expected => {:value => "baz", :type => :string},
                :actual => {:value => "baz", :type => :string},
                :common_type => :string
              }],
              [2, {
                :state => :missing,
                :expected => {:value => "quux", :type => :string},
                :actual => nil,
                :common_type => nil
              }],
              [3, {
                :state => :missing,
                :expected => {:value => "blargh", :type => :string},
                :actual => nil,
                :common_type => nil
              }]
            ]
          }],
          [2, {
            :state => :equal,
            :expected => {:value => "ying", :type => :string},
            :actual => {:value => "ying", :type => :string},
            :common_type => :string
          }]
        ]
      }
      actual.must == expected
    end
    
    specify "deeper arrays with variously differing arrays" do
      actual = @differ.diff(
        [
          "foo",
          ["bar", ["baz", "quux"]],
          "ying",
          ["blargh", "zing", "fooz", ["raz", ["vermouth", "eee", "ffff"]]]
        ],
        [
          "foz",
          "bar",
          "ying",
          ["blargh", "gragh", 1, ["raz", ["ralston"]], ["foreal", ["zap"]]]
        ]
      )
      expected = {
        :state => :inequal,
        :expected => {
          :value => [
            "foo",
            ["bar", ["baz", "quux"]],
            "ying",
            ["blargh", "zing", "fooz", ["raz", ["vermouth", "eee", "ffff"]]]
          ],
          :type => :array
        },
        :actual => {
          :value => [
            "foz",
            "bar",
            "ying",
            ["blargh", "gragh", 1, ["raz", ["ralston"]], ["foreal", ["zap"]]]
          ],
          :type => :array
        },
        :common_type => :array,
        :breakdown => [
          [0, {
            :state => :inequal,
            :expected => {:value => "foo", :type => :string},
            :actual => {:value => "foz", :type => :string},
            :common_type => :string
          }],
          [1, {
            :state => :inequal,
            :expected => {:value => ["bar", ["baz", "quux"]], :type => :array},
            :actual => {:value => "bar", :type => :string},
            :common_type => nil
          }],
          [2, {
            :state => :equal,
            :expected => {:value => "ying", :type => :string},
            :actual => {:value => "ying", :type => :string},
            :common_type => :string
          }],
          [3, {
            :state => :inequal,
            :expected => {:value => ["blargh", "zing", "fooz", ["raz", ["vermouth", "eee", "ffff"]]], :type => :array},
            :actual => {:value => ["blargh", "gragh", 1, ["raz", ["ralston"]], ["foreal", ["zap"]]], :type => :array},
            :common_type => :array,
            :breakdown => [
              [0, {
                :state => :equal,
                :expected => {:value => "blargh", :type => :string},
                :actual => {:value => "blargh", :type => :string},
                :common_type => :string
              }],
              [1, {
                :state => :inequal,
                :expected => {:value => "zing", :type => :string},
                :actual => {:value => "gragh", :type => :string},
                :common_type => :string
              }],
              [2, {
                :state => :inequal,
                :expected => {:value => "fooz", :type => :string},
                :actual => {:value => 1, :type => :number},
                :common_type => nil
              }],
              [3, {
                :state => :inequal,
                :expected => {:value => ["raz", ["vermouth", "eee", "ffff"]], :type => :array},
                :actual => {:value => ["raz", ["ralston"]], :type => :array},
                :common_type => :array,
                :breakdown => [
                  [0, {
                    :state => :equal,
                    :expected => {:value => "raz", :type => :string},
                    :actual => {:value => "raz", :type => :string},
                    :common_type => :string
                  }],
                  [1, {
                    :state => :inequal,
                    :expected => {:value => ["vermouth", "eee", "ffff"], :type => :array},
                    :actual => {:value => ["ralston"], :type => :array},
                    :common_type => :array,
                    :breakdown => [
                      [0, {
                        :state => :inequal,
                        :expected => {:value => "vermouth", :type => :string},
                        :actual => {:value => "ralston", :type => :string},
                        :common_type => :string
                      }],
                      [1, {
                        :state => :missing,
                        :expected => {:value => "eee", :type => :string},
                        :actual => nil,
                        :common_type => nil
                      }],
                      [2, {
                        :state => :missing,
                        :expected => {:value => "ffff", :type => :string},
                        :actual => nil,
                        :common_type => nil
                      }]
                    ]
                  }]
                ]
              }],
              [4, {
                :state => :surplus,
                :expected => nil,
                :actual => {:value => ["foreal", ["zap"]], :type => :array},
                :common_type => nil
              }]
            ]
          }]
        ]
      }
      actual.must == expected
    end
  end
end