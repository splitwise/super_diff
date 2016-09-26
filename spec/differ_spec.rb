require 'spec_helper'

describe SuperDiff::Differ do
  describe '.diff', 'generates correct data for' do
    specify "same strings" do
      actual = described_class.diff("foo", "foo")
      expected = {
        :state => :equal,
        :old_element => {:value => "foo", :type => :string},
        :new_element => {:value => "foo", :type => :string},
        :common_type => :string
      }
      actual.should == expected
    end

    specify "differing strings" do
      actual = described_class.diff("foo", "bar")
      expected = {
        :state => :inequal,
        :old_element => {:value => "foo", :type => :string},
        :new_element => {:value => "bar", :type => :string},
        :common_type => :string
      }
      actual.should == expected
    end

    specify "same numbers" do
      actual = described_class.diff(1, 1)
      expected = {
        :state => :equal,
        :old_element => {:value => 1, :type => :number},
        :new_element => {:value => 1, :type => :number},
        :common_type => :number
      }
      actual.should == expected
    end

    specify "differing numbers" do
      actual = described_class.diff(1, 2)
      expected = {
        :state => :inequal,
        :old_element => {:value => 1, :type => :number},
        :new_element => {:value => 2, :type => :number},
        :common_type => :number
      }
      actual.should == expected
    end

    specify "values of differing simple types" do
      actual = described_class.diff("foo", 1)
      expected = {
        :state => :inequal,
        :old_element => {:value => "foo", :type => :string},
        :new_element => {:value => 1, :type => :number},
        :common_type => nil
      }
      actual.should == expected
    end

    specify "values of differing complex types" do
      actual = described_class.diff("foo", %w(zing zang))
      expected = {
        :state => :inequal,
        :old_element => {:value => "foo", :type => :string},
        :new_element => {:value => %w(zing zang), :type => :array, :size => 2},
        :common_type => nil
      }
      actual.should == expected
    end

    specify "shallow arrays of same size but with differing elements" do
      actual = described_class.diff(["foo", "bar"], ["foo", "baz"])
      expected = {
        :state => :inequal,
        :old_element => {:value => ["foo", "bar"], :type => :array, :size => 2},
        :new_element => {:value => ["foo", "baz"], :type => :array, :size => 2},
        :common_type => :array,
        :details => [
          [0, {
            :state => :equal,
            :old_element => {:value => "foo", :type => :string},
            :new_element => {:value => "foo", :type => :string},
            :common_type => :string
          }],
          [1, {
            :state => :inequal,
            :old_element => {:value => "bar", :type => :string},
            :new_element => {:value => "baz", :type => :string},
            :common_type => :string
          }]
        ]
      }
      actual.should == expected
    end

    specify "shallow arrays with inserted elements" do
      actual = described_class.diff(
        %w(a b),
        %w(a 1 2 b),
      )
      expected = {
        :state => :inequal,
        :old_element => {:value => %w(a b), :type => :array, :size => 2},
        :new_element => {:value => %w(a 1 2 b), :type => :array, :size => 4},
        :common_type => :array,
        :details => [
          [0, {
            :state => :equal,
            :old_element => {:value => "a", :type => :string},
            :new_element => {:value => "a", :type => :string},
            :common_type => :string
          }],
          [1, {
            :state => :inequal,
            :old_element => {:value => "b", :type => :string},
            :new_element => {:value => "1", :type => :string},
            :common_type => :string
          }],
          [2, {
            :state => :surplus,
            :old_element => nil,
            :new_element => {:value => "2", :type => :string},
            :common_type => nil
          }],
          [3, {
            :state => :surplus,
            :old_element => nil,
            :new_element => {:value => "b", :type => :string},
            :common_type => nil
          }]
        ]
      }
      actual.should == expected
    end

    specify "deep arrays of same size but with differing elements" do
      actual = described_class.diff(
        [["foo", "bar"], ["baz", "quux"]],
        [["foo", "biz"], ["baz", "quarks"]]
      )
      expected = {
        :state => :inequal,
        :old_element => {:value => [["foo", "bar"], ["baz", "quux"]], :type => :array, :size => 2},
        :new_element => {:value => [["foo", "biz"], ["baz", "quarks"]], :type => :array, :size => 2},
        :common_type => :array,
        :details => [
          [0, {
            :state => :inequal,
            :old_element => {:value => ["foo", "bar"], :type => :array, :size => 2},
            :new_element => {:value => ["foo", "biz"], :type => :array, :size => 2},
            :common_type => :array,
            :details => [
              [0, {
                :state => :equal,
                :old_element => {:value => "foo", :type => :string},
                :new_element => {:value => "foo", :type => :string},
                :common_type => :string
              }],
              [1, {
                :state => :inequal,
                :old_element => {:value => "bar", :type => :string},
                :new_element => {:value => "biz", :type => :string},
                :common_type => :string
              }]
            ]
          }],
          [1, {
            :state => :inequal,
            :old_element => {:value => ["baz", "quux"], :type => :array, :size => 2},
            :new_element => {:value => ["baz", "quarks"], :type => :array, :size => 2},
            :common_type => :array,
            :details => [
              [0, {
                :state => :equal,
                :old_element => {:value => "baz", :type => :string},
                :new_element => {:value => "baz", :type => :string},
                :common_type => :string
              }],
              [1, {
                :state => :inequal,
                :old_element => {:value => "quux", :type => :string},
                :new_element => {:value => "quarks", :type => :string},
                :common_type => :string
              }]
            ]
          }]
        ]
      }
      actual.should == expected
    end

    specify "deeper arrays with differing elements" do
      actual = described_class.diff(
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
        :old_element => {
          :value => [
            "foo",
            ["bar", ["baz", "quux"]],
            "ying",
            ["blargh", "zing", "fooz", ["raz", ["vermouth"]]]
          ],
          :type => :array,
          :size => 4
        },
        :new_element => {
          :value => [
            "foz",
            "bar",
            "ying",
            ["blargh", "gragh", 1, ["raz", ["ralston"]]]
          ],
          :type => :array,
          :size => 4
        },
        :common_type => :array,
        :details => [
          [0, {
            :state => :inequal,
            :old_element => {:value => "foo", :type => :string},
            :new_element => {:value => "foz", :type => :string},
            :common_type => :string
          }],
          [1, {
            :state => :inequal,
            :old_element => {:value => ["bar", ["baz", "quux"]], :type => :array, :size => 2},
            :new_element => {:value => "bar", :type => :string},
            :common_type => nil
          }],
          [2, {
            :state => :equal,
            :old_element => {:value => "ying", :type => :string},
            :new_element => {:value => "ying", :type => :string},
            :common_type => :string
          }],
          [3, {
            :state => :inequal,
            :old_element => {
              :value => ["blargh", "zing", "fooz", ["raz", ["vermouth"]]],
              :type => :array,
              :size => 4
            },
            :new_element => {
              :value => ["blargh", "gragh", 1, ["raz", ["ralston"]]],
              :type => :array,
              :size => 4
            },
            :common_type => :array,
            :details => [
              [0, {
                :state => :equal,
                :old_element => {:value => "blargh", :type => :string},
                :new_element => {:value => "blargh", :type => :string},
                :common_type => :string
              }],
              [1, {
                :state => :inequal,
                :old_element => {:value => "zing", :type => :string},
                :new_element => {:value => "gragh", :type => :string},
                :common_type => :string
              }],
              [2, {
                :state => :inequal,
                :old_element => {:value => "fooz", :type => :string},
                :new_element => {:value => 1, :type => :number},
                :common_type => nil
              }],
              [3, {
                :state => :inequal,
                :old_element => {:value => ["raz", ["vermouth"]], :type => :array, :size => 2},
                :new_element => {:value => ["raz", ["ralston"]], :type => :array, :size => 2},
                :common_type => :array,
                :details => [
                  [0, {
                    :state => :equal,
                    :old_element => {:value => "raz", :type => :string},
                    :new_element => {:value => "raz", :type => :string},
                    :common_type => :string
                  }],
                  [1, {
                    :state => :inequal,
                    :old_element => {:value => ["vermouth"], :type => :array, :size => 1},
                    :new_element => {:value => ["ralston"], :type => :array, :size => 1},
                    :common_type => :array,
                    :details => [
                      [0, {
                        :state => :inequal,
                        :old_element => {:value => "vermouth", :type => :string},
                        :new_element => {:value => "ralston", :type => :string},
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
      actual.should == expected
    end

    specify "shallow arrays with surplus elements" do
      actual = described_class.diff(["foo", "bar"], ["foo", "bar", "baz", "quux"])
      expected = {
        :state => :inequal,
        :old_element => {:value => ["foo", "bar"], :type => :array, :size => 2},
        :new_element => {:value => ["foo", "bar", "baz", "quux"], :type => :array, :size => 4},
        :common_type => :array,
        :details => [
          [0, {
            :state => :equal,
            :old_element => {:value => "foo", :type => :string},
            :new_element => {:value => "foo", :type => :string},
            :common_type => :string
          }],
          [1, {
            :state => :equal,
            :old_element => {:value => "bar", :type => :string},
            :new_element => {:value => "bar", :type => :string},
            :common_type => :string
          }],
          [2, {
            :state => :surplus,
            :old_element => nil,
            :new_element => {:value => "baz", :type => :string},
            :common_type => nil
          }],
          [3, {
            :state => :surplus,
            :old_element => nil,
            :new_element => {:value => "quux", :type => :string},
            :common_type => nil
          }]
        ]
      }
      actual.should == expected
    end

    specify "shallow arrays with missing elements" do
      actual = described_class.diff(["foo", "bar", "baz", "quux"], ["foo", "bar"])
      expected = {
        :state => :inequal,
        :old_element => {:value => ["foo", "bar", "baz", "quux"], :type => :array, :size => 4},
        :new_element => {:value => ["foo", "bar"], :type => :array, :size => 2},
        :common_type => :array,
        :details => [
          [0, {
            :state => :equal,
            :old_element => {:value => "foo", :type => :string},
            :new_element => {:value => "foo", :type => :string},
            :common_type => :string
          }],
          [1, {
            :state => :equal,
            :old_element => {:value => "bar", :type => :string},
            :new_element => {:value => "bar", :type => :string},
            :common_type => :string
          }],
          [2, {
            :state => :missing,
            :old_element => {:value => "baz", :type => :string},
            :new_element => nil,
            :common_type => nil
          }],
          [3, {
            :state => :missing,
            :old_element => {:value => "quux", :type => :string},
            :new_element => nil,
            :common_type => nil
          }]
        ]
      }
      actual.should == expected
    end

    specify "deep arrays with surplus elements" do
      actual = described_class.diff(
        ["foo", ["bar", "baz"], "ying"],
        ["foo", ["bar", "baz", "quux", "blargh"], "ying"]
      )
      expected = {
        :state => :inequal,
        :old_element => {:value => ["foo", ["bar", "baz"], "ying"], :type => :array, :size => 3},
        :new_element => {:value => ["foo", ["bar", "baz", "quux", "blargh"], "ying"], :type => :array, :size => 3},
        :common_type => :array,
        :details => [
          [0, {
            :state => :equal,
            :old_element => {:value => "foo", :type => :string},
            :new_element => {:value => "foo", :type => :string},
            :common_type => :string
          }],
          [1, {
            :state => :inequal,
            :old_element => {:value => ["bar", "baz"], :type => :array, :size => 2},
            :new_element => {:value => ["bar", "baz", "quux", "blargh"], :type => :array, :size => 4},
            :common_type => :array,
            :details => [
              [0, {
                :state => :equal,
                :old_element => {:value => "bar", :type => :string},
                :new_element => {:value => "bar", :type => :string},
                :common_type => :string
              }],
              [1, {
                :state => :equal,
                :old_element => {:value => "baz", :type => :string},
                :new_element => {:value => "baz", :type => :string},
                :common_type => :string
              }],
              [2, {
                :state => :surplus,
                :old_element => nil,
                :new_element => {:value => "quux", :type => :string},
                :common_type => nil
              }],
              [3, {
                :state => :surplus,
                :old_element => nil,
                :new_element => {:value => "blargh", :type => :string},
                :common_type => nil
              }]
            ]
          }],
          [2, {
            :state => :equal,
            :old_element => {:value => "ying", :type => :string},
            :new_element => {:value => "ying", :type => :string},
            :common_type => :string
          }]
        ]
      }
      actual.should == expected
    end

    specify "deep arrays with missing elements" do
      actual = described_class.diff(
        ["foo", ["bar", "baz", "quux", "blargh"], "ying"],
        ["foo", ["bar", "baz"], "ying"]
      )
      expected = {
        :state => :inequal,
        :old_element => {:value => ["foo", ["bar", "baz", "quux", "blargh"], "ying"], :type => :array, :size => 3},
        :new_element => {:value => ["foo", ["bar", "baz"], "ying"], :type => :array, :size => 3},
        :common_type => :array,
        :details => [
          [0, {
            :state => :equal,
            :old_element => {:value => "foo", :type => :string},
            :new_element => {:value => "foo", :type => :string},
            :common_type => :string
          }],
          [1, {
            :state => :inequal,
            :old_element => {:value => ["bar", "baz", "quux", "blargh"], :type => :array, :size => 4},
            :new_element => {:value => ["bar", "baz"], :type => :array, :size => 2},
            :common_type => :array,
            :details => [
              [0, {
                :state => :equal,
                :old_element => {:value => "bar", :type => :string},
                :new_element => {:value => "bar", :type => :string},
                :common_type => :string
              }],
              [1, {
                :state => :equal,
                :old_element => {:value => "baz", :type => :string},
                :new_element => {:value => "baz", :type => :string},
                :common_type => :string
              }],
              [2, {
                :state => :missing,
                :old_element => {:value => "quux", :type => :string},
                :new_element => nil,
                :common_type => nil
              }],
              [3, {
                :state => :missing,
                :old_element => {:value => "blargh", :type => :string},
                :new_element => nil,
                :common_type => nil
              }]
            ]
          }],
          [2, {
            :state => :equal,
            :old_element => {:value => "ying", :type => :string},
            :new_element => {:value => "ying", :type => :string},
            :common_type => :string
          }]
        ]
      }
      actual.should == expected
    end

    specify "deeper arrays with variously differing arrays" do
      actual = described_class.diff(
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
        :old_element => {
          :value => [
            "foo",
            ["bar", ["baz", "quux"]],
            "ying",
            ["blargh", "zing", "fooz", ["raz", ["vermouth", "eee", "ffff"]]]
          ],
          :type => :array,
          :size => 4
        },
        :new_element => {
          :value => [
            "foz",
            "bar",
            "ying",
            ["blargh", "gragh", 1, ["raz", ["ralston"]], ["foreal", ["zap"]]]
          ],
          :type => :array,
          :size => 4
        },
        :common_type => :array,
        :details => [
          [0, {
            :state => :inequal,
            :old_element => {:value => "foo", :type => :string},
            :new_element => {:value => "foz", :type => :string},
            :common_type => :string
          }],
          [1, {
            :state => :inequal,
            :old_element => {:value => ["bar", ["baz", "quux"]], :type => :array, :size => 2},
            :new_element => {:value => "bar", :type => :string},
            :common_type => nil
          }],
          [2, {
            :state => :equal,
            :old_element => {:value => "ying", :type => :string},
            :new_element => {:value => "ying", :type => :string},
            :common_type => :string
          }],
          [3, {
            :state => :inequal,
            :old_element => {
              :value => ["blargh", "zing", "fooz", ["raz", ["vermouth", "eee", "ffff"]]],
              :type => :array,
              :size => 4
            },
            :new_element => {
              :value => ["blargh", "gragh", 1, ["raz", ["ralston"]], ["foreal", ["zap"]]],
              :type => :array,
              :size => 5
            },
            :common_type => :array,
            :details => [
              [0, {
                :state => :equal,
                :old_element => {:value => "blargh", :type => :string},
                :new_element => {:value => "blargh", :type => :string},
                :common_type => :string
              }],
              [1, {
                :state => :inequal,
                :old_element => {:value => "zing", :type => :string},
                :new_element => {:value => "gragh", :type => :string},
                :common_type => :string
              }],
              [2, {
                :state => :inequal,
                :old_element => {:value => "fooz", :type => :string},
                :new_element => {:value => 1, :type => :number},
                :common_type => nil
              }],
              [3, {
                :state => :inequal,
                :old_element => {:value => ["raz", ["vermouth", "eee", "ffff"]], :type => :array, :size => 2},
                :new_element => {:value => ["raz", ["ralston"]], :type => :array, :size => 2},
                :common_type => :array,
                :details => [
                  [0, {
                    :state => :equal,
                    :old_element => {:value => "raz", :type => :string},
                    :new_element => {:value => "raz", :type => :string},
                    :common_type => :string
                  }],
                  [1, {
                    :state => :inequal,
                    :old_element => {:value => ["vermouth", "eee", "ffff"], :type => :array, :size => 3},
                    :new_element => {:value => ["ralston"], :type => :array, :size => 1},
                    :common_type => :array,
                    :details => [
                      [0, {
                        :state => :inequal,
                        :old_element => {:value => "vermouth", :type => :string},
                        :new_element => {:value => "ralston", :type => :string},
                        :common_type => :string
                      }],
                      [1, {
                        :state => :missing,
                        :old_element => {:value => "eee", :type => :string},
                        :new_element => nil,
                        :common_type => nil
                      }],
                      [2, {
                        :state => :missing,
                        :old_element => {:value => "ffff", :type => :string},
                        :new_element => nil,
                        :common_type => nil
                      }]
                    ]
                  }]
                ]
              }],
              [4, {
                :state => :surplus,
                :old_element => nil,
                :new_element => {:value => ["foreal", ["zap"]], :type => :array, :size => 2},
                :common_type => nil
              }]
            ]
          }]
        ]
      }
      actual.should == expected
    end

    specify "shallow hashes of same size but differing elements" do
      actual = described_class.diff(
        {"foo" => "bar", "baz" => "quux"},
        {"foo" => "bar", "baz" => "quarx"}
      )
      expected = {
        :state => :inequal,
        :old_element => {:value => {"foo" => "bar", "baz" => "quux"}, :type => :hash, :size => 2},
        :new_element => {:value => {"foo" => "bar", "baz" => "quarx"}, :type => :hash, :size => 2},
        :common_type => :hash,
        :details => [
          ["foo", {
            :state => :equal,
            :old_element => {:value => "bar", :type => :string},
            :new_element => {:value => "bar", :type => :string},
            :common_type => :string
          }],
          ["baz", {
            :state => :inequal,
            :old_element => {:value => "quux", :type => :string},
            :new_element => {:value => "quarx", :type => :string},
            :common_type => :string
          }]
        ]
      }
      actual.should == expected
    end

    specify "deep hashes of same size but differing elements" do
      actual = described_class.diff(
        {"one" => {"foo" => "bar", "baz" => "quux"}, :two => {"ying" => 1, "zing" => :zang}},
        {"one" => {"foo" => "boo", "baz" => "quux"}, :two => {"ying" => "yang", "zing" => :bananas}}
      )
      expected = {
        :state => :inequal,
        :old_element => {
          :value => {"one" => {"foo" => "bar", "baz" => "quux"}, :two => {"ying" => 1, "zing" => :zang}},
          :type => :hash,
          :size => 2
        },
        :new_element => {
          :value => {"one" => {"foo" => "boo", "baz" => "quux"}, :two => {"ying" => "yang", "zing" => :bananas}},
          :type => :hash,
          :size => 2
        },
        :common_type => :hash,
        :details => [
          ["one", {
            :state => :inequal,
            :old_element => {:value => {"foo" => "bar", "baz" => "quux"}, :type => :hash, :size => 2},
            :new_element => {:value =>  {"foo" => "boo", "baz" => "quux"}, :type => :hash, :size => 2},
            :common_type => :hash,
            :details => [
              ["foo", {
                :state => :inequal,
                :old_element => {:value => "bar", :type => :string},
                :new_element => {:value => "boo", :type => :string},
                :common_type => :string
              }],
              ["baz", {
                :state => :equal,
                :old_element => {:value => "quux", :type => :string},
                :new_element => {:value => "quux", :type => :string},
                :common_type => :string
              }]
            ]
          }],
          [:two, {
            :state => :inequal,
            :old_element => {:value => {"ying" => 1, "zing" => :zang}, :type => :hash, :size => 2},
            :new_element => {:value => {"ying" => "yang", "zing" => :bananas}, :type => :hash, :size => 2},
            :common_type => :hash,
            :details => [
              ["ying", {
                :state => :inequal,
                :old_element => {:value => 1, :type => :number},
                :new_element => {:value => "yang", :type => :string},
                :common_type => nil
              }],
              ["zing", {
                :state => :inequal,
                :old_element => {:value => :zang, :type => :symbol},
                :new_element => {:value => :bananas, :type => :symbol},
                :common_type => :symbol
              }]
            ]
          }]
        ]
      }
      actual.should == expected
    end

    specify "deeper hashes with differing elements" do
      actual = described_class.diff(
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
        :old_element => {
          :value => {
            "foo" => {1 => {"baz" => {"quux" => 2}, "foz" => {"fram" => "frazzle"}}},
            "biz" => {:fiz => "gram", 1 => {2 => :sym}}
          },
          :type => :hash,
          :size => 2
        },
        :new_element => {
          :value => {
            "foo" => {1 => {"baz" => "quarx", "foz" => {"fram" => "razzle"}}},
            "biz" => {:fiz => "graeme", 1 => 3}
          },
          :type => :hash,
          :size => 2
        },
        :common_type => :hash,
        :details => [
          ["foo", {
            :state => :inequal,
            :old_element => {
              :value => {1 => {"baz" => {"quux" => 2}, "foz" => {"fram" => "frazzle"}}},
              :type => :hash,
              :size => 1
            },
            :new_element => {
              :value => {1 => {"baz" => "quarx", "foz" => {"fram" => "razzle"}}},
              :type => :hash,
              :size => 1
            },
            :common_type => :hash,
            :details => [
              [1, {
                :state => :inequal,
                :old_element => {
                  :value => {"baz" => {"quux" => 2}, "foz" => {"fram" => "frazzle"}},
                  :type => :hash,
                  :size => 2
                },
                :new_element => {
                  :value => {"baz" => "quarx", "foz" => {"fram" => "razzle"}},
                  :type => :hash,
                  :size => 2
                },
                :common_type => :hash,
                :details => [
                  ["baz", {
                    :state => :inequal,
                    :old_element => {:value => {"quux" => 2}, :type => :hash, :size => 1},
                    :new_element => {:value => "quarx", :type => :string},
                    :common_type => nil
                  }],
                  ["foz", {
                    :state => :inequal,
                    :old_element => {:value => {"fram" => "frazzle"}, :type => :hash, :size => 1},
                    :new_element => {:value => {"fram" => "razzle"}, :type => :hash, :size => 1},
                    :common_type => :hash,
                    :details => [
                      ["fram", {
                        :state => :inequal,
                        :old_element => {:value => "frazzle", :type => :string},
                        :new_element => {:value => "razzle", :type => :string},
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
            :old_element => {:value => {:fiz => "gram", 1 => {2 => :sym}}, :type => :hash, :size => 2},
            :new_element => {:value => {:fiz => "graeme", 1 => 3}, :type => :hash, :size => 2},
            :common_type => :hash,
            :details => [
              [:fiz, {
                :state => :inequal,
                :old_element => {:value => "gram", :type => :string},
                :new_element => {:value => "graeme", :type => :string},
                :common_type => :string
              }],
              [1, {
                :state => :inequal,
                :old_element => {:value => {2 => :sym}, :type => :hash, :size => 1},
                :new_element => {:value => 3, :type => :number},
                :common_type => nil
              }]
            ]
          }]
        ]
      }
      actual.should == expected
    end

    specify "shallow hashes with surplus elements" do
      actual = described_class.diff(
        {"foo" => "bar"},
        {"foo" => "bar", "baz" => "quux", "ying" => "yang"}
      )
      expected = {
        :state => :inequal,
        :old_element => {:value => {"foo" => "bar"}, :type => :hash, :size => 1},
        :new_element => {:value => {"foo" => "bar", "baz" => "quux", "ying" => "yang"}, :type => :hash, :size => 3},
        :common_type => :hash,
        :details => [
          ["foo", {
            :state => :equal,
            :old_element => {:value => "bar", :type => :string},
            :new_element => {:value => "bar", :type => :string},
            :common_type => :string
          }],
          ["baz", {
            :state => :surplus,
            :old_element => nil,
            :new_element => {:value => "quux", :type => :string},
            :common_type => nil
          }],
          ["ying", {
            :state => :surplus,
            :old_element => nil,
            :new_element => {:value => "yang", :type => :string},
            :common_type => nil
          }]
        ]
      }
      actual.should == expected
    end

    specify "shallow hashes with missing elements" do
      actual = described_class.diff(
        {"foo" => "bar", "baz" => "quux", "ying" => "yang"},
        {"foo" => "bar"}
      )
      expected = {
        :state => :inequal,
        :old_element => {:value => {"foo" => "bar", "baz" => "quux", "ying" => "yang"}, :type => :hash, :size => 3},
        :new_element => {:value => {"foo" => "bar"}, :type => :hash, :size => 1},
        :common_type => :hash,
        :details => [
          ["foo", {
            :state => :equal,
            :old_element => {:value => "bar", :type => :string},
            :new_element => {:value => "bar", :type => :string},
            :common_type => :string
          }],
          ["baz", {
            :state => :missing,
            :old_element => {:value => "quux", :type => :string},
            :new_element => nil,
            :common_type => nil
          }],
          ["ying", {
            :state => :missing,
            :old_element => {:value => "yang", :type => :string},
            :new_element => nil,
            :common_type => nil
          }]
        ]
      }
      actual.should == expected
    end

    specify "deep hashes with surplus elements" do
      actual = described_class.diff(
        {"one" => {"foo" => "bar"}},
        {"one" => {"foo" => "bar", "baz" => "quux", "ying" => "yang"}}
      )
      expected = {
        :state => :inequal,
        :old_element => {:value => {"one" => {"foo" => "bar"}}, :type => :hash, :size => 1},
        :new_element => {:value => {"one" => {"foo" => "bar", "baz" => "quux", "ying" => "yang"}}, :type => :hash, :size => 1},
        :common_type => :hash,
        :details => [
          ["one", {
            :state => :inequal,
            :old_element => {:value => {"foo" => "bar"}, :type => :hash, :size => 1},
            :new_element => {:value => {"foo" => "bar", "baz" => "quux", "ying" => "yang"}, :type => :hash, :size => 3},
            :common_type => :hash,
            :details => [
              ["foo", {
                :state => :equal,
                :old_element => {:value => "bar", :type => :string},
                :new_element => {:value => "bar", :type => :string},
                :common_type => :string
              }],
              ["baz", {
                :state => :surplus,
                :old_element => nil,
                :new_element => {:value => "quux", :type => :string},
                :common_type => nil
              }],
              ["ying", {
                :state => :surplus,
                :old_element => nil,
                :new_element => {:value => "yang", :type => :string},
                :common_type => nil
              }]
            ]
          }]
        ]
      }
      actual.should == expected
    end

    specify "deep hashes with missing elements" do
      actual = described_class.diff(
        {"one" => {"foo" => "bar", "baz" => "quux", "ying" => "yang"}},
        {"one" => {"foo" => "bar"}}
      )
      expected = {
        :state => :inequal,
        :old_element => {
          :value => {"one" => {"foo" => "bar", "baz" => "quux", "ying" => "yang"}},
          :type => :hash,
          :size => 1
        },
        :new_element => {
          :value => {"one" => {"foo" => "bar"}},
          :type => :hash,
          :size => 1
        },
        :common_type => :hash,
        :details => [
          ["one", {
            :state => :inequal,
            :old_element => {
              :value => {"foo" => "bar", "baz" => "quux", "ying" => "yang"},
              :type => :hash,
              :size => 3
            },
            :new_element => {
              :value => {"foo" => "bar"},
              :type => :hash,
              :size => 1
            },
            :common_type => :hash,
            :details => [
              ["foo", {
                :state => :equal,
                :old_element => {:value => "bar", :type => :string},
                :new_element => {:value => "bar", :type => :string},
                :common_type => :string
              }],
              ["baz", {
                :state => :missing,
                :old_element => {:value => "quux", :type => :string},
                :new_element => nil,
                :common_type => nil
              }],
              ["ying", {
                :state => :missing,
                :old_element => {:value => "yang", :type => :string},
                :new_element => nil,
                :common_type => nil
              }]
            ]
          }]
        ]
      }
      actual.should == expected
    end

    specify "deeper hashes with variously differing hashes" do
      actual = described_class.diff(
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
        :old_element => {
          :value => {
            "foo" => {1 => {"baz" => {"quux" => 2}, "foz" => {"fram" => "frazzle"}}},
            "biz" => {:fiz => "gram", 1 => {2 => :sym}},
            "bananas" => {:apple => 11}
          },
          :type => :hash,
          :size => 3
        },
        :new_element => {
          :value => {
            "foo" => {1 => {"foz" => {"fram" => "razzle"}}},
            "biz" => {42 => {:raz => "matazz"}, :fiz => "graeme", 1 => 3}
          },
          :type => :hash,
          :size => 2
        },
        :common_type => :hash,
        :details => [
          ["foo", {
            :state => :inequal,
            :old_element => {
              :value => {1 => {"baz" => {"quux" => 2}, "foz" => {"fram" => "frazzle"}}},
              :type => :hash,
              :size => 1
            },
            :new_element => {
              :value => {1 => {"foz" => {"fram" => "razzle"}}},
              :type => :hash,
              :size => 1
            },
            :common_type => :hash,
            :details => [
              [1, {
                :state => :inequal,
                :old_element => {
                  :value => {"baz" => {"quux" => 2}, "foz" => {"fram" => "frazzle"}},
                  :type => :hash,
                  :size => 2
                },
                :new_element => {
                  :value => {"foz" => {"fram" => "razzle"}},
                  :type => :hash,
                  :size => 1
                },
                :common_type => :hash,
                :details => [
                  ["baz", {
                    :state => :missing,
                    :old_element => {:value => {"quux" => 2}, :type => :hash, :size => 1},
                    :new_element => nil,
                    :common_type => nil
                  }],
                  ["foz", {
                    :state => :inequal,
                    :old_element => {:value => {"fram" => "frazzle"}, :type => :hash, :size => 1},
                    :new_element => {:value => {"fram" => "razzle"}, :type => :hash, :size => 1},
                    :common_type => :hash,
                    :details => [
                      ["fram", {
                        :state => :inequal,
                        :old_element => {:value => "frazzle", :type => :string},
                        :new_element => {:value => "razzle", :type => :string},
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
            :old_element => {:value => {:fiz => "gram", 1 => {2 => :sym}}, :type => :hash, :size => 2},
            :new_element => {:value => {42 => {:raz => "matazz"}, :fiz => "graeme", 1 => 3}, :type => :hash, :size => 3},
            :common_type => :hash,
            :details => [
              [:fiz, {
                :state => :inequal,
                :old_element => {:value => "gram", :type => :string},
                :new_element => {:value => "graeme", :type => :string},
                :common_type => :string
              }],
              [1, {
                :state => :inequal,
                :old_element => {:value => {2 => :sym}, :type => :hash, :size => 1},
                :new_element => {:value => 3, :type => :number},
                :common_type => nil
              }],
              [42, {
                :state => :surplus,
                :old_element => nil,
                :new_element => {:value => {:raz => "matazz"}, :type => :hash, :size => 1},
                :common_type => nil
              }]
            ]
          }],
          ["bananas", {
            :state => :missing,
            :old_element => {:value => {:apple => 11}, :type => :hash, :size => 1},
            :new_element => nil,
            :common_type => nil
          }]
        ]
      }
      actual.should == expected
    end

    specify "arrays and hashes, mixed" do
      actual = described_class.diff(
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
        :old_element => {
          :value => {
            "foo" => {1 => {"baz" => {"quux" => 2}, "foz" => ["apple", "bananna", "orange"]}},
            "biz" => {:fiz => ["bing", "bong", "bam"], 1 => {2 => :sym}},
            "bananas" => {:apple => 11}
          },
          :type => :hash,
          :size => 3
        },
        :new_element => {
          :value => {
            "foo" => {1 => {"foz" => ["apple", "banana", "orange"]}},
            "biz" => {42 => {:raz => "matazz"}, :fiz => ["bang", "bong", "bam", "splat"], 1 => 3}
          },
          :type => :hash,
          :size => 2
        },
        :common_type => :hash,
        :details => [
          ["foo", {
            :state => :inequal,
            :old_element => {
              :value => {1 => {"baz" => {"quux" => 2}, "foz" => ["apple", "bananna", "orange"]}},
              :type => :hash,
              :size => 1
            },
            :new_element => {
              :value => {1 => {"foz" => ["apple", "banana", "orange"]}},
              :type => :hash,
              :size => 1
            },
            :common_type => :hash,
            :details => [
              [1, {
                :state => :inequal,
                :old_element => {
                  :value => {"baz" => {"quux" => 2}, "foz" => ["apple", "bananna", "orange"]},
                  :type => :hash,
                  :size => 2
                },
                :new_element => {
                  :value => {"foz" => ["apple", "banana", "orange"]},
                  :type => :hash,
                  :size => 1
                },
                :common_type => :hash,
                :details => [
                  ["baz", {
                    :state => :missing,
                    :old_element => {:value => {"quux" => 2}, :type => :hash, :size => 1},
                    :new_element => nil,
                    :common_type => nil,
                  }],
                  ["foz", {
                    :state => :inequal,
                    :old_element => {:value => ["apple", "bananna", "orange"], :type => :array, :size => 3},
                    :new_element => {:value => ["apple", "banana", "orange"], :type => :array, :size => 3},
                    :common_type => :array,
                    :details => [
                      [0, {
                        :state => :equal,
                        :old_element => {:value => "apple", :type => :string},
                        :new_element => {:value => "apple", :type => :string},
                        :common_type => :string
                      }],
                      [1, {
                        :state => :inequal,
                        :old_element => {:value => "bananna", :type => :string},
                        :new_element => {:value => "banana", :type => :string},
                        :common_type => :string
                      }],
                      [2, {
                        :state => :equal,
                        :old_element => {:value => "orange", :type => :string},
                        :new_element => {:value => "orange", :type => :string},
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
            :old_element => {
              :value => {:fiz => ["bing", "bong", "bam"], 1 => {2 => :sym}},
              :type => :hash,
              :size => 2
            },
            :new_element => {
              :value => {42 => {:raz => "matazz"}, :fiz => ["bang", "bong", "bam", "splat"], 1 => 3},
              :type => :hash,
              :size => 3
            },
            :common_type => :hash,
            :details => [
              [:fiz, {
                :state => :inequal,
                :old_element => {:value => ["bing", "bong", "bam"], :type => :array, :size => 3},
                :new_element => {:value => ["bang", "bong", "bam", "splat"], :type => :array, :size => 4},
                :common_type => :array,
                :details => [
                  [0, {
                    :state => :inequal,
                    :old_element => {:value => "bing", :type => :string},
                    :new_element => {:value => "bang", :type => :string},
                    :common_type => :string
                  }],
                  [1, {
                    :state => :equal,
                    :old_element => {:value => "bong", :type => :string},
                    :new_element => {:value => "bong", :type => :string},
                    :common_type => :string,
                  }],
                  [2, {
                    :state => :equal,
                    :old_element => {:value => "bam", :type => :string},
                    :new_element => {:value => "bam", :type => :string},
                    :common_type => :string,
                  }],
                  [3, {
                    :state => :surplus,
                    :old_element => nil,
                    :new_element => {:value => "splat", :type => :string},
                    :common_type => nil
                  }]
                ]
              }],
              [1, {
                :state => :inequal,
                :old_element => {:value => {2 => :sym}, :type => :hash, :size => 1},
                :new_element => {:value => 3, :type => :number},
                :common_type => nil
              }],
              [42, {
                :state => :surplus,
                :old_element => nil,
                :new_element => {:value => {:raz => "matazz"}, :type => :hash, :size => 1},
                :common_type => nil
              }]
            ]
          }],
          ["bananas", {
            :state => :missing,
            :old_element => {:value => {:apple => 11}, :type => :hash, :size => 1},
            :new_element => nil,
            :common_type => nil
          }]
        ]
      }
      actual.should == expected
    end
  end
end
