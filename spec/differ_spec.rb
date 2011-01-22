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
    
    specify "shallow hashes of same size but differing elements" do
      actual = @differ.diff(
        {"foo" => "bar", "baz" => "quux"},
        {"foo" => "bar", "baz" => "quarx"}
      )
      expected = {
        :state => :inequal,
        :expected => {:value => {"foo" => "bar", "baz" => "quux"}, :type => :hash},
        :actual => {:value => {"foo" => "bar", "baz" => "quarx"}, :type => :hash},
        :common_type => :hash,
        :breakdown => [
          ["foo", {
            :state => :equal,
            :expected => {:value => "bar", :type => :string},
            :actual => {:value => "bar", :type => :string},
            :common_type => :string
          }],
          ["baz", {
            :state => :inequal,
            :expected => {:value => "quux", :type => :string},
            :actual => {:value => "quarx", :type => :string},
            :common_type => :string
          }]
        ]
      }
      actual.must == expected
    end
    
    specify "deep hashes of same size but differing elements" do
      actual = @differ.diff(
        {"one" => {"foo" => "bar", "baz" => "quux"}, :two => {"ying" => 1, "zing" => :zang}},
        {"one" => {"foo" => "boo", "baz" => "quux"}, :two => {"ying" => "yang", "zing" => :bananas}}
      )
      expected = {
        :state => :inequal,
        :expected => {
          :value => {"one" => {"foo" => "bar", "baz" => "quux"}, :two => {"ying" => 1, "zing" => :zang}},
          :type => :hash
        },
        :actual => {
          :value => {"one" => {"foo" => "boo", "baz" => "quux"}, :two => {"ying" => "yang", "zing" => :bananas}},
          :type => :hash
        },
        :common_type => :hash,
        :breakdown => [
          ["one", {
            :state => :inequal,
            :expected => {:value => {"foo" => "bar", "baz" => "quux"}, :type => :hash},
            :actual => {:value =>  {"foo" => "boo", "baz" => "quux"}, :type => :hash},
            :common_type => :hash,
            :breakdown => [
              ["foo", {
                :state => :inequal,
                :expected => {:value => "bar", :type => :string},
                :actual => {:value => "boo", :type => :string},
                :common_type => :string
              }],
              ["baz", {
                :state => :equal,
                :expected => {:value => "quux", :type => :string},
                :actual => {:value => "quux", :type => :string},
                :common_type => :string
              }]
            ]
          }],
          [:two, {
            :state => :inequal,
            :expected => {:value => {"ying" => 1, "zing" => :zang}, :type => :hash},
            :actual => {:value => {"ying" => "yang", "zing" => :bananas}, :type => :hash},
            :common_type => :hash,
            :breakdown => [
              ["ying", {
                :state => :inequal,
                :expected => {:value => 1, :type => :number},
                :actual => {:value => "yang", :type => :string},
                :common_type => nil
              }],
              ["zing", {
                :state => :inequal,
                :expected => {:value => :zang, :type => :symbol},
                :actual => {:value => :bananas, :type => :symbol},
                :common_type => :symbol
              }]
            ]
          }]
        ]
      }
      actual.must == expected
    end
    
    specify "deeper hashes with differing elements" do
      actual = @differ.diff(
        {
          "foo" => {1 => {"baz" => {"quux" => 2}, "foz" => {"fram" => "frazzle"}}},
          "biz" => {:fiz => "gram", 1 => {2 => :sym}}
        },
        {
          "foo" => {1 => {"baz" => "quarx", "foz" => {"fram" => "razzle"}}},
          "biz" => {:fiz => "graeme", 1 => 3}
        }
      )
      expected = {
        :state => :inequal,
        :expected => {
          :value => {
            "foo" => {1 => {"baz" => {"quux" => 2}, "foz" => {"fram" => "frazzle"}}},
            "biz" => {:fiz => "gram", 1 => {2 => :sym}}
          },
          :type => :hash
        },
        :actual => {
          :value => {
            "foo" => {1 => {"baz" => "quarx", "foz" => {"fram" => "razzle"}}},
            "biz" => {:fiz => "graeme", 1 => 3}
          },
          :type => :hash
        },
        :common_type => :hash,
        :breakdown => [
          ["foo", {
            :state => :inequal,
            :expected => {
              :value => {1 => {"baz" => {"quux" => 2}, "foz" => {"fram" => "frazzle"}}},
              :type => :hash
            },
            :actual => {
              :value => {1 => {"baz" => "quarx", "foz" => {"fram" => "razzle"}}},
              :type => :hash
            },
            :common_type => :hash,
            :breakdown => [
              [1, {
                :state => :inequal,
                :expected => {
                  :value => {"baz" => {"quux" => 2}, "foz" => {"fram" => "frazzle"}},
                  :type => :hash
                },
                :actual => {
                  :value => {"baz" => "quarx", "foz" => {"fram" => "razzle"}},
                  :type => :hash
                },
                :common_type => :hash,
                :breakdown => [
                  ["baz", {
                    :state => :inequal,
                    :expected => {:value => {"quux" => 2}, :type => :hash},
                    :actual => {:value => "quarx", :type => :string},
                    :common_type => nil
                  }],
                  ["foz", {
                    :state => :inequal,
                    :expected => {:value => {"fram" => "frazzle"}, :type => :hash},
                    :actual => {:value => {"fram" => "razzle"}, :type => :hash},
                    :common_type => :hash,
                    :breakdown => [
                      ["fram", {
                        :state => :inequal,
                        :expected => {:value => "frazzle", :type => :string},
                        :actual => {:value => "razzle", :type => :string},
                        :common_type => :string
                      }]
                    ]
                  }]
                ]
              }]
            ]
          }],
          ["biz", {
            :state => :inequal,
            :expected => {:value => {:fiz => "gram", 1 => {2 => :sym}}, :type => :hash},
            :actual => {:value => {:fiz => "graeme", 1 => 3}, :type => :hash},
            :common_type => :hash,
            :breakdown => [
              [:fiz, {
                :state => :inequal,
                :expected => {:value => "gram", :type => :string},
                :actual => {:value => "graeme", :type => :string},
                :common_type => :string
              }],
              [1, {
                :state => :inequal,
                :expected => {:value => {2 => :sym}, :type => :hash},
                :actual => {:value => 3, :type => :number},
                :common_type => nil
              }]
            ]
          }]
        ]
      }
      actual.must == expected
    end
    
    specify "shallow hashes with surplus elements" do
      actual = @differ.diff(
        {"foo" => "bar"},
        {"foo" => "bar", "baz" => "quux", "ying" => "yang"}
      )
      expected = {
        :state => :inequal,
        :expected => {:value => {"foo" => "bar"}, :type => :hash},
        :actual => {:value => {"foo" => "bar", "baz" => "quux", "ying" => "yang"}, :type => :hash},
        :common_type => :hash,
        :breakdown => [
          ["foo", {
            :state => :equal,
            :expected => {:value => "bar", :type => :string},
            :actual => {:value => "bar", :type => :string},
            :common_type => :string
          }],
          ["baz", {
            :state => :surplus,
            :expected => nil,
            :actual => {:value => "quux", :type => :string},
            :common_type => nil
          }],
          ["ying", {
            :state => :surplus,
            :expected => nil,
            :actual => {:value => "yang", :type => :string},
            :common_type => nil
          }]
        ]
      }
      actual.must == expected
    end
    
    specify "shallow hashes with missing elements" do
      actual = @differ.diff(
        {"foo" => "bar", "baz" => "quux", "ying" => "yang"},
        {"foo" => "bar"}
      )
      expected = {
        :state => :inequal,
        :expected => {:value => {"foo" => "bar", "baz" => "quux", "ying" => "yang"}, :type => :hash},
        :actual => {:value => {"foo" => "bar"}, :type => :hash},
        :common_type => :hash,
        :breakdown => [
          ["foo", {
            :state => :equal,
            :expected => {:value => "bar", :type => :string},
            :actual => {:value => "bar", :type => :string},
            :common_type => :string
          }],
          ["baz", {
            :state => :missing,
            :expected => {:value => "quux", :type => :string},
            :actual => nil,
            :common_type => nil
          }],
          ["ying", {
            :state => :missing,
            :expected => {:value => "yang", :type => :string},
            :actual => nil,
            :common_type => nil
          }]
        ]
      }
      actual.must == expected
    end
    
    specify "deep hashes with surplus elements" do
      actual = @differ.diff(
        {"one" => {"foo" => "bar"}},
        {"one" => {"foo" => "bar", "baz" => "quux", "ying" => "yang"}}
      )
      expected = {
        :state => :inequal,
        :expected => {:value => {"one" => {"foo" => "bar"}}, :type => :hash},
        :actual => {:value => {"one" => {"foo" => "bar", "baz" => "quux", "ying" => "yang"}}, :type => :hash},
        :common_type => :hash,
        :breakdown => [
          ["one", {
            :state => :inequal,
            :expected => {:value => {"foo" => "bar"}, :type => :hash},
            :actual => {:value => {"foo" => "bar", "baz" => "quux", "ying" => "yang"}, :type => :hash},
            :common_type => :hash,
            :breakdown => [
              ["foo", {
                :state => :equal,
                :expected => {:value => "bar", :type => :string},
                :actual => {:value => "bar", :type => :string},
                :common_type => :string
              }],
              ["baz", {
                :state => :surplus,
                :expected => nil,
                :actual => {:value => "quux", :type => :string},
                :common_type => nil
              }],
              ["ying", {
                :state => :surplus,
                :expected => nil,
                :actual => {:value => "yang", :type => :string},
                :common_type => nil
              }]
            ]
          }]
        ]
      }
      actual.must == expected
    end
    
    specify "deep hashes with missing elements" do
      actual = @differ.diff(
        {"one" => {"foo" => "bar", "baz" => "quux", "ying" => "yang"}},
        {"one" => {"foo" => "bar"}}
      )
      expected = {
        :state => :inequal,
        :expected => {:value => {"one" => {"foo" => "bar", "baz" => "quux", "ying" => "yang"}}, :type => :hash},
        :actual => {:value => {"one" => {"foo" => "bar"}}, :type => :hash},
        :common_type => :hash,
        :breakdown => [
          ["one", {
            :state => :inequal,
            :expected => {:value => {"foo" => "bar", "baz" => "quux", "ying" => "yang"}, :type => :hash},
            :actual => {:value => {"foo" => "bar"}, :type => :hash},
            :common_type => :hash,
            :breakdown => [
              ["foo", {
                :state => :equal,
                :expected => {:value => "bar", :type => :string},
                :actual => {:value => "bar", :type => :string},
                :common_type => :string
              }],
              ["baz", {
                :state => :missing,
                :expected => {:value => "quux", :type => :string},
                :actual => nil,
                :common_type => nil
              }],
              ["ying", {
                :state => :missing,
                :expected => {:value => "yang", :type => :string},
                :actual => nil,
                :common_type => nil
              }]
            ]
          }]
        ]
      }
      actual.must == expected
    end
    
    specify "deeper hashes with variously differing hashes" do
      actual = @differ.diff(
        {
          "foo" => {1 => {"baz" => {"quux" => 2}, "foz" => {"fram" => "frazzle"}}},
          "biz" => {:fiz => "gram", 1 => {2 => :sym}},
          "bananas" => {:apple => 11}
        },
        {
          "foo" => {1 => {"foz" => {"fram" => "razzle"}}},
          "biz" => {42 => {:raz => "matazz"}, :fiz => "graeme", 1 => 3}
        }
      )
      expected = {
        :state => :inequal,
        :expected => {
          :value => {
            "foo" => {1 => {"baz" => {"quux" => 2}, "foz" => {"fram" => "frazzle"}}},
            "biz" => {:fiz => "gram", 1 => {2 => :sym}},
            "bananas" => {:apple => 11}
          },
          :type => :hash
        },
        :actual => {
          :value => {
            "foo" => {1 => {"foz" => {"fram" => "razzle"}}},
            "biz" => {42 => {:raz => "matazz"}, :fiz => "graeme", 1 => 3}
          },
          :type => :hash
        },
        :common_type => :hash,
        :breakdown => [
          ["foo", {
            :state => :inequal,
            :expected => {
              :value => {1 => {"baz" => {"quux" => 2}, "foz" => {"fram" => "frazzle"}}},
              :type => :hash
            },
            :actual => {
              :value => {1 => {"foz" => {"fram" => "razzle"}}},
              :type => :hash
            },
            :common_type => :hash,
            :breakdown => [
              [1, {
                :state => :inequal,
                :expected => {
                  :value => {"baz" => {"quux" => 2}, "foz" => {"fram" => "frazzle"}},
                  :type => :hash
                },
                :actual => {
                  :value => {"foz" => {"fram" => "razzle"}},
                  :type => :hash
                },
                :common_type => :hash,
                :breakdown => [
                  ["baz", {
                    :state => :missing,
                    :expected => {:value => {"quux" => 2}, :type => :hash},
                    :actual => nil,
                    :common_type => nil
                  }],
                  ["foz", {
                    :state => :inequal,
                    :expected => {:value => {"fram" => "frazzle"}, :type => :hash},
                    :actual => {:value => {"fram" => "razzle"}, :type => :hash},
                    :common_type => :hash,
                    :breakdown => [
                      ["fram", {
                        :state => :inequal,
                        :expected => {:value => "frazzle", :type => :string},
                        :actual => {:value => "razzle", :type => :string},
                        :common_type => :string
                      }]
                    ]
                  }]
                ]
              }]
            ]
          }],
          ["biz", {
            :state => :inequal,
            :expected => {:value => {:fiz => "gram", 1 => {2 => :sym}}, :type => :hash},
            :actual => {:value => {42 => {:raz => "matazz"}, :fiz => "graeme", 1 => 3}, :type => :hash},
            :common_type => :hash,
            :breakdown => [
              [:fiz, {
                :state => :inequal,
                :expected => {:value => "gram", :type => :string},
                :actual => {:value => "graeme", :type => :string},
                :common_type => :string
              }],
              [1, {
                :state => :inequal,
                :expected => {:value => {2 => :sym}, :type => :hash},
                :actual => {:value => 3, :type => :number},
                :common_type => nil
              }],
              [42, {
                :state => :surplus,
                :expected => nil,
                :actual => {:value => {:raz => "matazz"}, :type => :hash},
                :common_type => nil
              }]
            ]
          }],
          ["bananas", {
            :state => :missing,
            :expected => {:value => {:apple => 11}, :type => :hash},
            :actual => nil,
            :common_type => nil
          }]
        ]
      }
      actual.must == expected
    end
    
    specify "arrays and hashes, mixed" do
      actual = @differ.diff(
        {
          "foo" => {1 => {"baz" => {"quux" => 2}, "foz" => ["apple", "bananna", "orange"]}},
          "biz" => {:fiz => ["bing", "bong", "bam"], 1 => {2 => :sym}},
          "bananas" => {:apple => 11}
        },
        {
          "foo" => {1 => {"foz" => ["apple", "banana", "orange"]}},
          "biz" => {42 => {:raz => "matazz"}, :fiz => ["bang", "bong", "bam", "splat"], 1 => 3}
        }
      )
      expected = {
        :state => :inequal,
        :expected => {
          :value => {
            "foo" => {1 => {"baz" => {"quux" => 2}, "foz" => ["apple", "bananna", "orange"]}},
            "biz" => {:fiz => ["bing", "bong", "bam"], 1 => {2 => :sym}},
            "bananas" => {:apple => 11}
          },
          :type => :hash
        },
        :actual => {
          :value => {
            "foo" => {1 => {"foz" => ["apple", "banana", "orange"]}},
            "biz" => {42 => {:raz => "matazz"}, :fiz => ["bang", "bong", "bam", "splat"], 1 => 3}
          },
          :type => :hash
        },
        :common_type => :hash,
        :breakdown => [
          ["foo", {
            :state => :inequal,
            :expected => {
              :value => {1 => {"baz" => {"quux" => 2}, "foz" => ["apple", "bananna", "orange"]}},
              :type => :hash
            },
            :actual => {
              :value => {1 => {"foz" => ["apple", "banana", "orange"]}},
              :type => :hash
            },
            :common_type => :hash,
            :breakdown => [
              [1, {
                :state => :inequal,
                :expected => {
                  :value => {"baz" => {"quux" => 2}, "foz" => ["apple", "bananna", "orange"]},
                  :type => :hash
                },
                :actual => {
                  :value => {"foz" => ["apple", "banana", "orange"]},
                  :type => :hash
                },
                :common_type => :hash,
                :breakdown => [
                  ["baz", {
                    :state => :missing,
                    :expected => {:value => {"quux" => 2}, :type => :hash},
                    :actual => nil,
                    :common_type => nil,
                  }],
                  ["foz", {
                    :state => :inequal,
                    :expected => {:value => ["apple", "bananna", "orange"], :type => :array},
                    :actual => {:value => ["apple", "banana", "orange"], :type => :array},
                    :common_type => :array,
                    :breakdown => [
                      [0, {
                        :state => :equal,
                        :expected => {:value => "apple", :type => :string},
                        :actual => {:value => "apple", :type => :string},
                        :common_type => :string
                      }],
                      [1, {
                        :state => :inequal,
                        :expected => {:value => "bananna", :type => :string},
                        :actual => {:value => "banana", :type => :string},
                        :common_type => :string
                      }],
                      [2, {
                        :state => :equal,
                        :expected => {:value => "orange", :type => :string},
                        :actual => {:value => "orange", :type => :string},
                        :common_type => :string
                      }]
                    ]
                  }]
                ]
              }]
            ]
          }],
          ["biz", {
            :state => :inequal,
            :expected => {
              :value => {:fiz => ["bing", "bong", "bam"], 1 => {2 => :sym}},
              :type => :hash
            },
            :actual => {
              :value => {42 => {:raz => "matazz"}, :fiz => ["bang", "bong", "bam", "splat"], 1 => 3},
              :type => :hash
            },
            :common_type => :hash,
            :breakdown => [
              [:fiz, {
                :state => :inequal,
                :expected => {:value => ["bing", "bong", "bam"], :type => :array},
                :actual => {:value => ["bang", "bong", "bam", "splat"], :type => :array},
                :common_type => :array,
                :breakdown => [
                  [0, {
                    :state => :inequal,
                    :expected => {:value => "bing", :type => :string},
                    :actual => {:value => "bang", :type => :string},
                    :common_type => :string
                  }],
                  [1, {
                    :state => :equal,
                    :expected => {:value => "bong", :type => :string},
                    :actual => {:value => "bong", :type => :string},
                    :common_type => :string,
                  }],
                  [2, {
                    :state => :equal,
                    :expected => {:value => "bam", :type => :string},
                    :actual => {:value => "bam", :type => :string},
                    :common_type => :string,
                  }],
                  [3, {
                    :state => :surplus,
                    :expected => nil,
                    :actual => {:value => "splat", :type => :string},
                    :common_type => nil
                  }]
                ]
              }],
              [1, {
                :state => :inequal,
                :expected => {:value => {2 => :sym}, :type => :hash},
                :actual => {:value => 3, :type => :number},
                :common_type => nil
              }],
              [42, {
                :state => :surplus,
                :expected => nil,
                :actual => {:value => {:raz => "matazz"}, :type => :hash},
                :common_type => nil
              }]
            ]
          }],
          ["bananas", {
            :state => :missing,
            :expected => {:value => {:apple => 11}, :type => :hash},
            :actual => nil,
            :common_type => nil
          }]
        ]
      }
      actual.must == expected
    end
  end
end