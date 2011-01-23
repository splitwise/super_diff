require File.expand_path('../spec_helper', __FILE__)

require 'stringio'

describe SuperDiff::Reporter do
  before do
    @stdout = StringIO.new
    @reporter = SuperDiff::Reporter.new(@stdout)
  end
  
  def out
    @stdout.string
  end
  
  describe '#report', 'outputs correct message for' do
    specify "same strings" do
      data = {
        :state => :equal,
        :expected => {:value => "foo", :type => :string},
        :actual => {:value => "foo", :type => :string},
        :common_type => :string
      }
      @reporter.report(data)
      out.must be_empty
    end
    
    specify "differing strings" do
      data = {
        :state => :inequal,
        :expected => {:value => "foo", :type => :string},
        :actual => {:value => "bar", :type => :string},
        :common_type => :string
      }
      @reporter.report(data)
      msg = <<EOT
Error: Differing strings.

Expected: "foo"
Got: "bar"
EOT
      out.must == msg
    end
    
    specify "same numbers" do
      data = {
        :state => :equal,
        :expected => {:value => 1, :type => :number},
        :actual => {:value => 1, :type => :number},
        :common_type => :number
      }
      @reporter.report(data)
      out.must be_empty
    end
    
    specify "differing numbers" do
      data = {
        :state => :inequal,
        :expected => {:value => 1, :type => :number},
        :actual => {:value => 2, :type => :number},
        :common_type => :number
      }
      @reporter.report(data)
      msg = <<EOT
Error: Differing numbers.

Expected: 1
Got: 2
EOT
      out.must == msg
    end
  
    specify "values of differing simple types" do
      data = {
        :state => :inequal,
        :expected => {:value => "foo", :type => :string},
        :actual => {:value => 1, :type => :number},
        :common_type => nil
      }
      @reporter.report(data)
      msg = <<EOT
Error: Values of differing type.

Expected: "foo"
Got: 1
EOT
      out.must == msg
    end
  
    specify "values of differing complex types" do
      data = {
        :state => :inequal,
        :expected => {:value => "foo", :type => :string},
        :actual => {:value => %w(zing zang), :type => :array},
        :common_type => nil
      }
      @reporter.report(data)
      msg = <<EOT
Error: Values of differing type.

Expected: "foo"
Got: ["zing", "zang"]
EOT
      out.must == msg
    end
  
    specify "shallow arrays of same size but differing elements" do
      data = {
        :state => :inequal,
        :expected => {:value => ["foo", "bar"], :type => :array, :size => 2},
        :actual => {:value => ["foo", "baz"], :type => :array, :size => 2},
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
      @reporter.report(data)
      msg = <<EOT
Error: Arrays of same size but with differing elements.

Expected: ["foo", "bar"]
Got: ["foo", "baz"]

Breakdown:
- *[1]: Differing strings.
  - Expected: "bar"
  - Got: "baz"
EOT
      out.must == msg
    end
  
    specify "deep arrays of same size but differing elements" do
      data = {
        :state => :inequal,
        :expected => {:value => [["foo", "bar"], ["baz", "quux"]], :type => :array, :size => 2},
        :actual => {:value => [["foo", "biz"], ["baz", "quarks"]], :type => :array, :size => 2},
        :common_type => :array,
        :breakdown => [
          [0, {
            :state => :inequal,
            :expected => {:value => ["foo", "bar"], :type => :array, :size => 2},
            :actual => {:value => ["foo", "biz"], :type => :array, :size => 2},
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
            :expected => {:value => ["baz", "quux"], :type => :array, :size => 2},
            :actual => {:value => ["baz", "quarks"], :type => :array, :size => 2},
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
      @reporter.report(data)
      msg = <<EOT
Error: Arrays of same size but with differing elements.

Expected: [["foo", "bar"], ["baz", "quux"]]
Got: [["foo", "biz"], ["baz", "quarks"]]

Breakdown:
- *[0]: Arrays of same size but with differing elements.
  - *[1]: Differing strings.
    - Expected: "bar"
    - Got: "biz"
- *[1]: Arrays of same size but with differing elements.
  - *[1]: Differing strings.
    - Expected: "quux"
    - Got: "quarks"
EOT
      out.must == msg
    end
  
    specify "deeper arrays with differing elements" do
      data = {
        :state => :inequal,
        :expected => {
          :value => [
            "foo",
            ["bar", ["baz", "quux"]],
            "ying",
            ["blargh", "zing", "fooz", ["raz", ["vermouth"]]]
          ],
          :type => :array,
          :size => 4
        },
        :actual => {
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
        :breakdown => [
          [0, {
            :state => :inequal,
            :expected => {:value => "foo", :type => :string},
            :actual => {:value => "foz", :type => :string},
            :common_type => :string
          }],
          [1, {
            :state => :inequal,
            :expected => {:value => ["bar", ["baz", "quux"]], :type => :array, :size => 2},
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
              :type => :array,
              :size => 4
            },
            :actual => {
              :value => ["blargh", "gragh", 1, ["raz", ["ralston"]]],
              :type => :array,
              :size => 4
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
                :expected => {:value => ["raz", ["vermouth"]], :type => :array, :size => 2},
                :actual => {:value => ["raz", ["ralston"]], :type => :array, :size => 2},
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
                    :expected => {:value => ["vermouth"], :type => :array, :size => 1},
                    :actual => {:value => ["ralston"], :type => :array, :size => 1},
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
      @reporter.report(data)
      msg = <<EOT
Error: Arrays of same size but with differing elements.

Expected: ["foo", ["bar", ["baz", "quux"]], "ying", ["blargh", "zing", "fooz", ["raz", ["vermouth"]]]]
Got: ["foz", "bar", "ying", ["blargh", "gragh", 1, ["raz", ["ralston"]]]]

Breakdown:
- *[0]: Differing strings.
  - Expected: "foo"
  - Got: "foz"
- *[1]: Values of differing type.
  - Expected: ["bar", ["baz", "quux"]]
  - Got: "bar"
- *[3]: Arrays of same size but with differing elements.
  - *[1]: Differing strings.
    - Expected: "zing"
    - Got: "gragh"
  - *[2]: Values of differing type.
    - Expected: "fooz"
    - Got: 1
  - *[3]: Arrays of same size but with differing elements.
    - *[1]: Arrays of same size but with differing elements.
      - *[0]: Differing strings.
        - Expected: "vermouth"
        - Got: "ralston"
EOT
      out.must == msg
    end
  
    specify "shallow arrays with surplus elements" do
      data = {
        :state => :inequal,
        :expected => {:value => ["foo", "bar"], :type => :array, :size => 2},
        :actual => {:value => ["foo", "bar", "baz", "quux"], :type => :array, :size => 4},
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
      @reporter.report(data)
      msg = <<EOT
Error: Arrays of differing size (no differing elements).

Expected: ["foo", "bar"]
Got: ["foo", "bar", "baz", "quux"]

Breakdown:
- *[2]: Expected to not be present, but found "baz".
- *[3]: Expected to not be present, but found "quux".
EOT
      out.must == msg
    end
  
    specify "shallow arrays with missing elements" do
      data = {
        :state => :inequal,
        :expected => {:value => ["foo", "bar", "baz", "quux"], :type => :array, :size => 4},
        :actual => {:value => ["foo", "bar"], :type => :array, :size => 2},
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
      @reporter.report(data)
      msg = <<EOT
Error: Arrays of differing size (no differing elements).

Expected: ["foo", "bar", "baz", "quux"]
Got: ["foo", "bar"]

Breakdown:
- *[2]: Expected to have been found, but missing "baz".
- *[3]: Expected to have been found, but missing "quux".
EOT
      out.must == msg
    end
  
    specify "deep arrays with surplus elements" do
      data = {
        :state => :inequal,
        :expected => {:value => ["foo", ["bar", "baz"], "ying"], :type => :array, :size => 3},
        :actual => {:value => ["foo", ["bar", "baz", "quux", "blargh"], "ying"], :type => :array, :size => 3},
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
            :expected => {:value => ["bar", "baz"], :type => :array, :size => 2},
            :actual => {:value => ["bar", "baz", "quux", "blargh"], :type => :array, :size => 4},
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
      @reporter.report(data)
      msg = <<EOT
Error: Arrays of same size but with differing elements.

Expected: ["foo", ["bar", "baz"], "ying"]
Got: ["foo", ["bar", "baz", "quux", "blargh"], "ying"]

Breakdown:
- *[1]: Arrays of differing size (no differing elements).
  - *[2]: Expected to not be present, but found "quux".
  - *[3]: Expected to not be present, but found "blargh".
EOT
      out.must == msg
    end
  
    specify "deep arrays with missing elements" do
      data = {
        :state => :inequal,
        :expected => {:value => ["foo", ["bar", "baz", "quux", "blargh"], "ying"], :type => :array, :size => 3},
        :actual => {:value => ["foo", ["bar", "baz"], "ying"], :type => :array, :size => 3},
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
            :expected => {:value => ["bar", "baz", "quux", "blargh"], :type => :array, :size => 4},
            :actual => {:value => ["bar", "baz"], :type => :array, :size => 2},
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
      @reporter.report(data)
      msg = <<EOT
Error: Arrays of same size but with differing elements.

Expected: ["foo", ["bar", "baz", "quux", "blargh"], "ying"]
Got: ["foo", ["bar", "baz"], "ying"]

Breakdown:
- *[1]: Arrays of differing size (no differing elements).
  - *[2]: Expected to have been found, but missing "quux".
  - *[3]: Expected to have been found, but missing "blargh".
EOT
      out.must == msg
    end
  
    specify "deeper arrays with variously differing arrays" do
      data = {
        :state => :inequal,
        :expected => {
          :value => [
            "foo",
            ["bar", ["baz", "quux"]],
            "ying",
            ["blargh", "zing", "fooz", ["raz", ["vermouth", "eee", "ffff"]]]
          ],
          :type => :array,
          :size => 4
        },
        :actual => {
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
        :breakdown => [
          [0, {
            :state => :inequal,
            :expected => {:value => "foo", :type => :string},
            :actual => {:value => "foz", :type => :string},
            :common_type => :string
          }],
          [1, {
            :state => :inequal,
            :expected => {:value => ["bar", ["baz", "quux"]], :type => :array, :size => 2},
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
              :value => ["blargh", "zing", "fooz", ["raz", ["vermouth", "eee", "ffff"]]],
              :type => :array,
              :size => 4
            },
            :actual => {
              :value => ["blargh", "gragh", 1, ["raz", ["ralston"]], ["foreal", ["zap"]]],
              :type => :array,
              :size => 5
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
                :expected => {:value => ["raz", ["vermouth", "eee", "ffff"]], :type => :array, :size => 2},
                :actual => {:value => ["raz", ["ralston"]], :type => :array, :size => 2},
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
                    :expected => {:value => ["vermouth", "eee", "ffff"], :type => :array, :size => 3},
                    :actual => {:value => ["ralston"], :type => :array, :size => 1},
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
                :actual => {:value => ["foreal", ["zap"]], :type => :array, :size => 2},
                :common_type => nil
              }]
            ]
          }]
        ]
      }
      @reporter.report(data)
      msg = <<EOT
Error: Arrays of same size but with differing elements.

Expected: ["foo", ["bar", ["baz", "quux"]], "ying", ["blargh", "zing", "fooz", ["raz", ["vermouth", "eee", "ffff"]]]]
Got: ["foz", "bar", "ying", ["blargh", "gragh", 1, ["raz", ["ralston"]], ["foreal", ["zap"]]]]

Breakdown:
- *[0]: Differing strings.
  - Expected: "foo"
  - Got: "foz"
- *[1]: Values of differing type.
  - Expected: ["bar", ["baz", "quux"]]
  - Got: "bar"
- *[3]: Arrays of differing size and elements.
  - *[1]: Differing strings.
    - Expected: "zing"
    - Got: "gragh"
  - *[2]: Values of differing type.
    - Expected: "fooz"
    - Got: 1
  - *[3]: Arrays of same size but with differing elements.
    - *[1]: Arrays of differing size and elements.
      - *[0]: Differing strings.
        - Expected: "vermouth"
        - Got: "ralston"
      - *[1]: Expected to have been found, but missing "eee".
      - *[2]: Expected to have been found, but missing "ffff".
  - *[4]: Expected to not be present, but found ["foreal", ["zap"]].
EOT
      out.must == msg
    end
  
    specify "shallow hashes of same size but differing elements" do
      data = {
        :state => :inequal,
        :expected => {:value => {"foo" => "bar", "baz" => "quux"}, :type => :hash, :size => 2},
        :actual => {:value => {"foo" => "bar", "baz" => "quarx"}, :type => :hash, :size => 2},
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
      @reporter.report(data)
      msg = <<EOT
Error: Hashes of same size but with differing elements.

Expected: {"foo"=>"bar", "baz"=>"quux"}
Got: {"foo"=>"bar", "baz"=>"quarx"}

Breakdown:
- *["baz"]: Differing strings.
  - Expected: "quux"
  - Got: "quarx"
EOT
      out.must == msg
    end
  
    specify "deep hashes of same size but differing elements" do
      data = {
        :state => :inequal,
        :expected => {
          :value => {"one" => {"foo" => "bar", "baz" => "quux"}, :two => {"ying" => 1, "zing" => :zang}},
          :type => :hash,
          :size => 2
        },
        :actual => {
          :value => {"one" => {"foo" => "boo", "baz" => "quux"}, :two => {"ying" => "yang", "zing" => :bananas}},
          :type => :hash,
          :size => 2
        },
        :common_type => :hash,
        :breakdown => [
          ["one", {
            :state => :inequal,
            :expected => {:value => {"foo" => "bar", "baz" => "quux"}, :type => :hash, :size => 2},
            :actual => {:value =>  {"foo" => "boo", "baz" => "quux"}, :type => :hash, :size => 2},
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
            :expected => {:value => {"ying" => 1, "zing" => :zang}, :type => :hash, :size => 2},
            :actual => {:value => {"ying" => "yang", "zing" => :bananas}, :type => :hash, :size => 2},
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
      @reporter.report(data)
      msg = <<EOT
Error: Hashes of same size but with differing elements.

Expected: {"one"=>{"foo"=>"bar", "baz"=>"quux"}, :two=>{"ying"=>1, "zing"=>:zang}}
Got: {"one"=>{"foo"=>"boo", "baz"=>"quux"}, :two=>{"ying"=>"yang", "zing"=>:bananas}}

Breakdown:
- *["one"]: Hashes of same size but with differing elements.
  - *["foo"]: Differing strings.
    - Expected: "bar"
    - Got: "boo"
- *[:two]: Hashes of same size but with differing elements.
  - *["ying"]: Values of differing type.
    - Expected: 1
    - Got: "yang"
  - *["zing"]: Differing symbols.
    - Expected: :zang
    - Got: :bananas
EOT
      out.must == msg
    end
  
    specify "deeper hashes with differing elements" do
      data = {
        :state => :inequal,
        :expected => {
          :value => {
            "foo" => {1 => {"baz" => {"quux" => 2}, "foz" => {"fram" => "frazzle"}}},
            "biz" => {:fiz => "gram", 1 => {2 => :sym}}
          },
          :type => :hash,
          :size => 2
        },
        :actual => {
          :value => {
            "foo" => {1 => {"baz" => "quarx", "foz" => {"fram" => "razzle"}}},
            "biz" => {:fiz => "graeme", 1 => 3}
          },
          :type => :hash,
          :size => 2
        },
        :common_type => :hash,
        :breakdown => [
          ["foo", {
            :state => :inequal,
            :expected => {
              :value => {1 => {"baz" => {"quux" => 2}, "foz" => {"fram" => "frazzle"}}},
              :type => :hash,
              :size => 1
            },
            :actual => {
              :value => {1 => {"baz" => "quarx", "foz" => {"fram" => "razzle"}}},
              :type => :hash,
              :size => 1
            },
            :common_type => :hash,
            :breakdown => [
              [1, {
                :state => :inequal,
                :expected => {
                  :value => {"baz" => {"quux" => 2}, "foz" => {"fram" => "frazzle"}},
                  :type => :hash,
                  :size => 2
                },
                :actual => {
                  :value => {"baz" => "quarx", "foz" => {"fram" => "razzle"}},
                  :type => :hash,
                  :size => 2
                },
                :common_type => :hash,
                :breakdown => [
                  ["baz", {
                    :state => :inequal,
                    :expected => {:value => {"quux" => 2}, :type => :hash, :size => 1},
                    :actual => {:value => "quarx", :type => :string},
                    :common_type => nil
                  }],
                  ["foz", {
                    :state => :inequal,
                    :expected => {:value => {"fram" => "frazzle"}, :type => :hash, :size => 1},
                    :actual => {:value => {"fram" => "razzle"}, :type => :hash, :size => 1},
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
            :expected => {:value => {:fiz => "gram", 1 => {2 => :sym}}, :type => :hash, :size => 2},
            :actual => {:value => {:fiz => "graeme", 1 => 3}, :type => :hash, :size => 2},
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
                :expected => {:value => {2 => :sym}, :type => :hash, :size => 1},
                :actual => {:value => 3, :type => :number},
                :common_type => nil
              }]
            ]
          }]
        ]
      }
      @reporter.report(data)
      msg = <<EOT
Error: Hashes of same size but with differing elements.

Expected: {"foo"=>{1=>{"baz"=>{"quux"=>2}, "foz"=>{"fram"=>"frazzle"}}}, "biz"=>{:fiz=>"gram", 1=>{2=>:sym}}}
Got: {"foo"=>{1=>{"baz"=>"quarx", "foz"=>{"fram"=>"razzle"}}}, "biz"=>{:fiz=>"graeme", 1=>3}}

Breakdown:
- *["foo"]: Hashes of same size but with differing elements.
  - *[1]: Hashes of same size but with differing elements.
    - *["baz"]: Values of differing type.
      - Expected: {"quux"=>2}
      - Got: "quarx"
    - *["foz"]: Hashes of same size but with differing elements.
      - *["fram"]: Differing strings.
        - Expected: "frazzle"
        - Got: "razzle"
- *["biz"]: Hashes of same size but with differing elements.
  - *[:fiz]: Differing strings.
    - Expected: "gram"
    - Got: "graeme"
  - *[1]: Values of differing type.
    - Expected: {2=>:sym}
    - Got: 3
EOT
      out.must == msg
    end
  
    specify "shallow hashes with surplus elements" do
      data = {
        :state => :inequal,
        :expected => {:value => {"foo" => "bar"}, :type => :hash, :size => 1},
        :actual => {:value => {"foo" => "bar", "baz" => "quux", "ying" => "yang"}, :type => :hash, :size => 3},
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
      @reporter.report(data)
      msg = <<EOT
Error: Hashes of differing size (no differing elements).

Expected: {"foo"=>"bar"}
Got: {"foo"=>"bar", "baz"=>"quux", "ying"=>"yang"}

Breakdown:
- *["baz"]: Expected to not be present, but found "quux".
- *["ying"]: Expected to not be present, but found "yang".
EOT
      out.must == msg
    end
  
    specify "shallow hashes with missing elements" do
      data = {
        :state => :inequal,
        :expected => {:value => {"foo" => "bar", "baz" => "quux", "ying" => "yang"}, :type => :hash, :size => 3},
        :actual => {:value => {"foo" => "bar"}, :type => :hash, :size => 1},
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
      @reporter.report(data)
      msg = <<EOT
Error: Hashes of differing size (no differing elements).

Expected: {"foo"=>"bar", "baz"=>"quux", "ying"=>"yang"}
Got: {"foo"=>"bar"}

Breakdown:
- *["baz"]: Expected to have been found, but missing "quux".
- *["ying"]: Expected to have been found, but missing "yang".
EOT
      out.must == msg
    end
  
    specify "deep hashes with surplus elements" do
      data = {
        :state => :inequal,
        :expected => {:value => {"one" => {"foo" => "bar"}}, :type => :hash, :size => 1},
        :actual => {:value => {"one" => {"foo" => "bar", "baz" => "quux", "ying" => "yang"}}, :type => :hash, :size => 1},
        :common_type => :hash,
        :breakdown => [
          ["one", {
            :state => :inequal,
            :expected => {:value => {"foo" => "bar"}, :type => :hash, :size => 1},
            :actual => {:value => {"foo" => "bar", "baz" => "quux", "ying" => "yang"}, :type => :hash, :size => 3},
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
      @reporter.report(data)
      msg = <<EOT
Error: Hashes of same size but with differing elements.

Expected: {"one"=>{"foo"=>"bar"}}
Got: {"one"=>{"foo"=>"bar", "baz"=>"quux", "ying"=>"yang"}}

Breakdown:
- *["one"]: Hashes of differing size (no differing elements).
  - *["baz"]: Expected to not be present, but found "quux".
  - *["ying"]: Expected to not be present, but found "yang".
EOT
      out.must == msg
    end
  
    specify "deep hashes with missing elements" do
      data = {
        :state => :inequal,
        :expected => {
          :value => {"one" => {"foo" => "bar", "baz" => "quux", "ying" => "yang"}},
          :type => :hash,
          :size => 1
        },
        :actual => {
          :value => {"one" => {"foo" => "bar"}},
          :type => :hash,
          :size => 1
        },
        :common_type => :hash,
        :breakdown => [
          ["one", {
            :state => :inequal,
            :expected => {
              :value => {"foo" => "bar", "baz" => "quux", "ying" => "yang"},
              :type => :hash,
              :size => 3
            },
            :actual => {
              :value => {"foo" => "bar"},
              :type => :hash,
              :size => 1
            },
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
      @reporter.report(data)
      msg = <<EOT
Error: Hashes of same size but with differing elements.

Expected: {"one"=>{"foo"=>"bar", "baz"=>"quux", "ying"=>"yang"}}
Got: {"one"=>{"foo"=>"bar"}}

Breakdown:
- *["one"]: Hashes of differing size (no differing elements).
  - *["baz"]: Expected to have been found, but missing "quux".
  - *["ying"]: Expected to have been found, but missing "yang".
EOT
      out.must == msg
    end
  
    specify "deeper hashes with variously differing hashes" do
      data = {
        :state => :inequal,
        :expected => {
          :value => {
            "foo" => {1 => {"baz" => {"quux" => 2}, "foz" => {"fram" => "frazzle"}}},
            "biz" => {:fiz => "gram", 1 => {2 => :sym}},
            "bananas" => {:apple => 11}
          },
          :type => :hash,
          :size => 3
        },
        :actual => {
          :value => {
            "foo" => {1 => {"foz" => {"fram" => "razzle"}}},
            "biz" => {42 => {:raz => "matazz"}, :fiz => "graeme", 1 => 3}
          },
          :type => :hash,
          :size => 2
        },
        :common_type => :hash,
        :breakdown => [
          ["foo", {
            :state => :inequal,
            :expected => {
              :value => {1 => {"baz" => {"quux" => 2}, "foz" => {"fram" => "frazzle"}}},
              :type => :hash,
              :size => 1
            },
            :actual => {
              :value => {1 => {"foz" => {"fram" => "razzle"}}},
              :type => :hash,
              :size => 1
            },
            :common_type => :hash,
            :breakdown => [
              [1, {
                :state => :inequal,
                :expected => {
                  :value => {"baz" => {"quux" => 2}, "foz" => {"fram" => "frazzle"}},
                  :type => :hash,
                  :size => 2
                },
                :actual => {
                  :value => {"foz" => {"fram" => "razzle"}},
                  :type => :hash,
                  :size => 1
                },
                :common_type => :hash,
                :breakdown => [
                  ["baz", {
                    :state => :missing,
                    :expected => {:value => {"quux" => 2}, :type => :hash, :size => 1},
                    :actual => nil,
                    :common_type => nil
                  }],
                  ["foz", {
                    :state => :inequal,
                    :expected => {:value => {"fram" => "frazzle"}, :type => :hash, :size => 1},
                    :actual => {:value => {"fram" => "razzle"}, :type => :hash, :size => 1},
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
            :expected => {:value => {:fiz => "gram", 1 => {2 => :sym}}, :type => :hash, :size => 2},
            :actual => {:value => {42 => {:raz => "matazz"}, :fiz => "graeme", 1 => 3}, :type => :hash, :size => 3},
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
                :expected => {:value => {2 => :sym}, :type => :hash, :size => 1},
                :actual => {:value => 3, :type => :number},
                :common_type => nil
              }],
              [42, {
                :state => :surplus,
                :expected => nil,
                :actual => {:value => {:raz => "matazz"}, :type => :hash, :size => 1},
                :common_type => nil
              }]
            ]
          }],
          ["bananas", {
            :state => :missing,
            :expected => {:value => {:apple => 11}, :type => :hash, :size => 1},
            :actual => nil,
            :common_type => nil
          }]
        ]
      }
      @reporter.report(data)
      msg = <<EOT
Error: Hashes of differing size and elements.

Expected: {"foo"=>{1=>{"baz"=>{"quux"=>2}, "foz"=>{"fram"=>"frazzle"}}}, "biz"=>{:fiz=>"gram", 1=>{2=>:sym}}, "bananas"=>{:apple=>11}}
Got: {"foo"=>{1=>{"foz"=>{"fram"=>"razzle"}}}, "biz"=>{42=>{:raz=>"matazz"}, :fiz=>"graeme", 1=>3}}

Breakdown:
- *["foo"]: Hashes of same size but with differing elements.
  - *[1]: Hashes of differing size and elements.
    - *["baz"]: Expected to have been found, but missing {"quux"=>2}.
    - *["foz"]: Hashes of same size but with differing elements.
      - *["fram"]: Differing strings.
        - Expected: "frazzle"
        - Got: "razzle"
- *["biz"]: Hashes of differing size and elements.
  - *[:fiz]: Differing strings.
    - Expected: "gram"
    - Got: "graeme"
  - *[1]: Values of differing type.
    - Expected: {2=>:sym}
    - Got: 3
  - *[42]: Expected to not be present, but found {:raz=>"matazz"}.
- *["bananas"]: Expected to have been found, but missing {:apple=>11}.
EOT
      out.must == msg
    end
  
    specify "arrays and hashes, mixed" do
      data = {
        :state => :inequal,
        :expected => {
          :value => {
            "foo" => {1 => {"baz" => {"quux" => 2}, "foz" => ["apple", "bananna", "orange"]}},
            "biz" => {:fiz => ["bing", "bong", "bam"], 1 => {2 => :sym}},
            "bananas" => {:apple => 11}
          },
          :type => :hash,
          :size => 3
        },
        :actual => {
          :value => {
            "foo" => {1 => {"foz" => ["apple", "banana", "orange"]}},
            "biz" => {42 => {:raz => "matazz"}, :fiz => ["bang", "bong", "bam", "splat"], 1 => 3}
          },
          :type => :hash,
          :size => 2
        },
        :common_type => :hash,
        :breakdown => [
          ["foo", {
            :state => :inequal,
            :expected => {
              :value => {1 => {"baz" => {"quux" => 2}, "foz" => ["apple", "bananna", "orange"]}},
              :type => :hash,
              :size => 1
            },
            :actual => {
              :value => {1 => {"foz" => ["apple", "banana", "orange"]}},
              :type => :hash,
              :size => 1
            },
            :common_type => :hash,
            :breakdown => [
              [1, {
                :state => :inequal,
                :expected => {
                  :value => {"baz" => {"quux" => 2}, "foz" => ["apple", "bananna", "orange"]},
                  :type => :hash,
                  :size => 2
                },
                :actual => {
                  :value => {"foz" => ["apple", "banana", "orange"]},
                  :type => :hash,
                  :size => 1
                },
                :common_type => :hash,
                :breakdown => [
                  ["baz", {
                    :state => :missing,
                    :expected => {:value => {"quux" => 2}, :type => :hash, :size => 1},
                    :actual => nil,
                    :common_type => nil,
                  }],
                  ["foz", {
                    :state => :inequal,
                    :expected => {:value => ["apple", "bananna", "orange"], :type => :array, :size => 3},
                    :actual => {:value => ["apple", "banana", "orange"], :type => :array, :size => 3},
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
              :type => :hash,
              :size => 2
            },
            :actual => {
              :value => {42 => {:raz => "matazz"}, :fiz => ["bang", "bong", "bam", "splat"], 1 => 3},
              :type => :hash,
              :size => 3
            },
            :common_type => :hash,
            :breakdown => [
              [:fiz, {
                :state => :inequal,
                :expected => {:value => ["bing", "bong", "bam"], :type => :array, :size => 3},
                :actual => {:value => ["bang", "bong", "bam", "splat"], :type => :array, :size => 4},
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
                :expected => {:value => {2 => :sym}, :type => :hash, :size => 1},
                :actual => {:value => 3, :type => :number},
                :common_type => nil
              }],
              [42, {
                :state => :surplus,
                :expected => nil,
                :actual => {:value => {:raz => "matazz"}, :type => :hash, :size => 1},
                :common_type => nil
              }]
            ]
          }],
          ["bananas", {
            :state => :missing,
            :expected => {:value => {:apple => 11}, :type => :hash, :size => 1},
            :actual => nil,
            :common_type => nil
          }]
        ]
      }
      @reporter.report(data)
      msg = <<EOT
Error: Hashes of differing size and elements.

Expected: {"foo"=>{1=>{"baz"=>{"quux"=>2}, "foz"=>["apple", "bananna", "orange"]}}, "biz"=>{:fiz=>["bing", "bong", "bam"], 1=>{2=>:sym}}, "bananas"=>{:apple=>11}}
Got: {"foo"=>{1=>{"foz"=>["apple", "banana", "orange"]}}, "biz"=>{42=>{:raz=>"matazz"}, :fiz=>["bang", "bong", "bam", "splat"], 1=>3}}

Breakdown:
- *["foo"]: Hashes of same size but with differing elements.
  - *[1]: Hashes of differing size and elements.
    - *["baz"]: Expected to have been found, but missing {"quux"=>2}.
    - *["foz"]: Arrays of same size but with differing elements.
      - *[1]: Differing strings.
        - Expected: "bananna"
        - Got: "banana"
- *["biz"]: Hashes of differing size and elements.
  - *[:fiz]: Arrays of differing size and elements.
    - *[0]: Differing strings.
      - Expected: "bing"
      - Got: "bang"
    - *[3]: Expected to not be present, but found "splat".
  - *[1]: Values of differing type.
    - Expected: {2=>:sym}
    - Got: 3
  - *[42]: Expected to not be present, but found {:raz=>"matazz"}.
- *["bananas"]: Expected to have been found, but missing {:apple=>11}.
EOT
      out.must == msg
    end
  
    specify "collapsed output" do
      pending
      @reporter.diff(
        {
          "foo" => {1 => {"baz" => {"quux" => 2}, "foz" => ["apple", "bananna", "orange"]}},
          "biz" => {:fiz => ["bing", "bong", "bam"], 1 => {2 => :sym}},
          "bananas" => {:apple => 11}
        },
        {
          "foo" => {1 => {"foz" => ["apple", "banana", "orange"]}},
          "biz" => {42 => {:raz => "matazz"}, :fiz => ["bang", "bong", "bam", "splat"], 1 => 3}
        },
        :collapsed => true
      )
      msg = <<EOT
Error: Hashes of differing size and elements.

Expected: {"foo"=>{1=>{"baz"=>{"quux"=>2}, "foz"=>["apple", "bananna", "orange"]}}, "biz"=>{:fiz=>["bing", "bong", "bam"], 1=>{2=>:sym}}, "bananas"=>{:apple=>11}}
Got: {"foo"=>{1=>{"foz"=>["apple", "banana", "orange"]}}, "biz"=>{42=>{:raz=>"matazz"}, :fiz=>["bang", "bong", "bam", "splat"], 1=>3}}

Breakdown:
- *["foo"][1]["baz"]: Expected to have been found, but missing {"quux"=>2}.
- *["foo"][1]["foz"][1]: Differing strings.
  - Expected: "bananna"
  - Got: "banana"
- *["biz"][:fiz][0]: Differing strings.
  - Expected: "bing"
  - Got: "bang"
- *["biz"][:fiz][3]: Expected to not be present, but found "splat".
- *["biz"][1]: Values of differing type.
  - Expected: {2=>:sym}
  - Got: 3
- *["biz"][42]: Expected to not be present, but found {:raz=>"matazz"}.
- *["bananas"]: Expected to have been found, but missing {:apple=>11}.
EOT
      out.must == msg
    end
  
    specify "custom string differ"
    
    specify "custom array differ"
  
    specify "custom hash differ"
  
    specify "custom object differ"
  end
end