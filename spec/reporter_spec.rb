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
        :old_element => {:value => "foo", :type => :string},
        :new_element => {:value => "foo", :type => :string},
        :common_type => :string
      }
      @reporter.report(data)
      out.must be_empty
    end

    specify "differing strings" do
      data = {
        :state => :inequal,
        :old_element => {:value => "foo", :type => :string},
        :new_element => {:value => "bar", :type => :string},
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
        :old_element => {:value => 1, :type => :number},
        :new_element => {:value => 1, :type => :number},
        :common_type => :number
      }
      @reporter.report(data)
      out.must be_empty
    end

    specify "differing numbers" do
      data = {
        :state => :inequal,
        :old_element => {:value => 1, :type => :number},
        :new_element => {:value => 2, :type => :number},
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
        :old_element => {:value => "foo", :type => :string},
        :new_element => {:value => 1, :type => :number},
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
        :old_element => {:value => "foo", :type => :string},
        :new_element => {:value => %w(zing zang), :type => :array},
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
      @reporter.report(data)
      msg = <<EOT
Error: Arrays of same size but with differing elements.

Expected: ["foo", "bar"]
Got: ["foo", "baz"]

Details:
- *[1]: Differing strings.
  - Expected: "bar"
  - Got: "baz"
EOT
      out.must == msg
    end

    specify "deep arrays of same size but differing elements" do
      data = {
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
      @reporter.report(data)
      msg = <<EOT
Error: Arrays of same size but with differing elements.

Expected: [["foo", "bar"], ["baz", "quux"]]
Got: [["foo", "biz"], ["baz", "quarks"]]

Details:
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
      @reporter.report(data)
      msg = <<EOT
Error: Arrays of same size but with differing elements.

Expected: ["foo", ["bar", ["baz", "quux"]], "ying", ["blargh", "zing", "fooz", ["raz", ["vermouth"]]]]
Got: ["foz", "bar", "ying", ["blargh", "gragh", 1, ["raz", ["ralston"]]]]

Details:
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
      @reporter.report(data)
      msg = <<EOT
Error: Arrays of differing size (no differing elements).

Expected: ["foo", "bar"]
Got: ["foo", "bar", "baz", "quux"]

Details:
- *[2]: Expected to not be present, but found "baz".
- *[3]: Expected to not be present, but found "quux".
EOT
      out.must == msg
    end

    specify "shallow arrays with missing elements" do
      data = {
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
      @reporter.report(data)
      msg = <<EOT
Error: Arrays of differing size (no differing elements).

Expected: ["foo", "bar", "baz", "quux"]
Got: ["foo", "bar"]

Details:
- *[2]: Expected to have been found, but missing "baz".
- *[3]: Expected to have been found, but missing "quux".
EOT
      out.must == msg
    end

    specify "deep arrays with surplus elements" do
      data = {
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
      @reporter.report(data)
      msg = <<EOT
Error: Arrays of same size but with differing elements.

Expected: ["foo", ["bar", "baz"], "ying"]
Got: ["foo", ["bar", "baz", "quux", "blargh"], "ying"]

Details:
- *[1]: Arrays of differing size (no differing elements).
  - *[2]: Expected to not be present, but found "quux".
  - *[3]: Expected to not be present, but found "blargh".
EOT
      out.must == msg
    end

    specify "deep arrays with missing elements" do
      data = {
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
      @reporter.report(data)
      msg = <<EOT
Error: Arrays of same size but with differing elements.

Expected: ["foo", ["bar", "baz", "quux", "blargh"], "ying"]
Got: ["foo", ["bar", "baz"], "ying"]

Details:
- *[1]: Arrays of differing size (no differing elements).
  - *[2]: Expected to have been found, but missing "quux".
  - *[3]: Expected to have been found, but missing "blargh".
EOT
      out.must == msg
    end

    specify "deeper arrays with variously differing arrays" do
      data = {
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
      @reporter.report(data)
      msg = <<EOT
Error: Arrays of same size but with differing elements.

Expected: ["foo", ["bar", ["baz", "quux"]], "ying", ["blargh", "zing", "fooz", ["raz", ["vermouth", "eee", "ffff"]]]]
Got: ["foz", "bar", "ying", ["blargh", "gragh", 1, ["raz", ["ralston"]], ["foreal", ["zap"]]]]

Details:
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
      @reporter.report(data)
      msg = <<EOT
Error: Hashes of same size but with differing elements.

Expected: {"foo"=>"bar", "baz"=>"quux"}
Got: {"foo"=>"bar", "baz"=>"quarx"}

Details:
- *["baz"]: Differing strings.
  - Expected: "quux"
  - Got: "quarx"
EOT
      out.must == msg
    end

    specify "deep hashes of same size but differing elements" do
      data = {
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
      @reporter.report(data)
      msg = <<EOT
Error: Hashes of same size but with differing elements.

Expected: {"one"=>{"foo"=>"bar", "baz"=>"quux"}, :two=>{"ying"=>1, "zing"=>:zang}}
Got: {"one"=>{"foo"=>"boo", "baz"=>"quux"}, :two=>{"ying"=>"yang", "zing"=>:bananas}}

Details:
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
      @reporter.report(data)
      msg = <<EOT
Error: Hashes of same size but with differing elements.

Expected: {"foo"=>{1=>{"baz"=>{"quux"=>2}, "foz"=>{"fram"=>"frazzle"}}}, "biz"=>{:fiz=>"gram", 1=>{2=>:sym}}}
Got: {"foo"=>{1=>{"baz"=>"quarx", "foz"=>{"fram"=>"razzle"}}}, "biz"=>{:fiz=>"graeme", 1=>3}}

Details:
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
      @reporter.report(data)
      msg = <<EOT
Error: Hashes of differing size (no differing elements).

Expected: {"foo"=>"bar"}
Got: {"foo"=>"bar", "baz"=>"quux", "ying"=>"yang"}

Details:
- *["baz"]: Expected to not be present, but found "quux".
- *["ying"]: Expected to not be present, but found "yang".
EOT
      out.must == msg
    end

    specify "shallow hashes with missing elements" do
      data = {
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
      @reporter.report(data)
      msg = <<EOT
Error: Hashes of differing size (no differing elements).

Expected: {"foo"=>"bar", "baz"=>"quux", "ying"=>"yang"}
Got: {"foo"=>"bar"}

Details:
- *["baz"]: Expected to have been found, but missing "quux".
- *["ying"]: Expected to have been found, but missing "yang".
EOT
      out.must == msg
    end

    specify "deep hashes with surplus elements" do
      data = {
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
      @reporter.report(data)
      msg = <<EOT
Error: Hashes of same size but with differing elements.

Expected: {"one"=>{"foo"=>"bar"}}
Got: {"one"=>{"foo"=>"bar", "baz"=>"quux", "ying"=>"yang"}}

Details:
- *["one"]: Hashes of differing size (no differing elements).
  - *["baz"]: Expected to not be present, but found "quux".
  - *["ying"]: Expected to not be present, but found "yang".
EOT
      out.must == msg
    end

    specify "deep hashes with missing elements" do
      data = {
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
      @reporter.report(data)
      msg = <<EOT
Error: Hashes of same size but with differing elements.

Expected: {"one"=>{"foo"=>"bar", "baz"=>"quux", "ying"=>"yang"}}
Got: {"one"=>{"foo"=>"bar"}}

Details:
- *["one"]: Hashes of differing size (no differing elements).
  - *["baz"]: Expected to have been found, but missing "quux".
  - *["ying"]: Expected to have been found, but missing "yang".
EOT
      out.must == msg
    end

    specify "deeper hashes with variously differing hashes" do
      data = {
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
      @reporter.report(data)
      msg = <<EOT
Error: Hashes of differing size and elements.

Expected: {"foo"=>{1=>{"baz"=>{"quux"=>2}, "foz"=>{"fram"=>"frazzle"}}}, "biz"=>{:fiz=>"gram", 1=>{2=>:sym}}, "bananas"=>{:apple=>11}}
Got: {"foo"=>{1=>{"foz"=>{"fram"=>"razzle"}}}, "biz"=>{42=>{:raz=>"matazz"}, :fiz=>"graeme", 1=>3}}

Details:
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
      @reporter.report(data)
      msg = <<EOT
Error: Hashes of differing size and elements.

Expected: {"foo"=>{1=>{"baz"=>{"quux"=>2}, "foz"=>["apple", "bananna", "orange"]}}, "biz"=>{:fiz=>["bing", "bong", "bam"], 1=>{2=>:sym}}, "bananas"=>{:apple=>11}}
Got: {"foo"=>{1=>{"foz"=>["apple", "banana", "orange"]}}, "biz"=>{42=>{:raz=>"matazz"}, :fiz=>["bang", "bong", "bam", "splat"], 1=>3}}

Details:
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
      data = {
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
      @reporter.report(data, :collapsed => true)
      msg = <<EOT
Error: Hashes of differing size and elements.

Expected: {"foo"=>{1=>{"baz"=>{"quux"=>2}, "foz"=>["apple", "bananna", "orange"]}}, "biz"=>{:fiz=>["bing", "bong", "bam"], 1=>{2=>:sym}}, "bananas"=>{:apple=>11}}
Got: {"foo"=>{1=>{"foz"=>["apple", "banana", "orange"]}}, "biz"=>{42=>{:raz=>"matazz"}, :fiz=>["bang", "bong", "bam", "splat"], 1=>3}}

Details:
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