require 'spec_helper'

describe SuperDiff::Reporter do
  let(:stdout) { StringIO.new }

  describe '.report', 'outputs correct message for' do
    specify "same strings" do
      change = {
        :state => :equal,
        :elements => {
          :old => {:value => "foo", :type => :string},
          :new => {:value => "foo", :type => :string},
          :common => {:value => nil, :type => :string}
        }
      }
      described_class.report(change, to: stdout)
      stdout.string.should be_empty
    end

    specify "differing strings" do
      change = {
        :state => :inequal,
        :elements => {
          :old => {:value => "foo", :type => :string},
          :new => {:value => "bar", :type => :string},
          :common => {:value => nil, :type => :string}
        }
      }
      described_class.report(change, to: stdout)
      msg = <<EOT
Error: Differing strings.

Expected: "foo"
Got: "bar"
EOT
      stdout.string.should == msg
    end

    specify "same numbers" do
      change = {
        :state => :equal,
        :elements => {
          :old => {:value => 1, :type => :number},
          :new => {:value => 1, :type => :number},
          :common => {:value => nil, :type => :number}
        }
      }
      described_class.report(change, to: stdout)
      stdout.string.should be_empty
    end

    specify "differing numbers" do
      change = {
        :state => :inequal,
        :elements => {
          :old => {:value => 1, :type => :number},
          :new => {:value => 2, :type => :number},
          :common => {:value => nil, :type => :number}
        }
      }
      described_class.report(change, to: stdout)
      msg = <<EOT
Error: Differing numbers.

Expected: 1
Got: 2
EOT
      stdout.string.should == msg
    end

    specify "values of differing simple types" do
      change = {
        :state => :inequal,
        :elements => {
          :old => {:value => "foo", :type => :string},
          :new => {:value => 1, :type => :number},
          :common => {:value => nil, :type => nil}
        }
      }
      described_class.report(change, to: stdout)
      msg = <<EOT
Error: Values of differing type.

Expected: "foo"
Got: 1
EOT
      stdout.string.should == msg
    end

    specify "values of differing complex types" do
      change = {
        :state => :inequal,
        :elements => {
          :old => {:value => "foo", :type => :string},
          :new => {:value => %w(zing zang), :type => :array},
          :common => {:value => nil, :type => nil}
        }
      }
      described_class.report(change, to: stdout)
      msg = <<EOT
Error: Values of differing type.

Expected: "foo"
Got: ["zing", "zang"]
EOT
      stdout.string.should == msg
    end

    specify "shallow arrays of same size but differing elements" do
      change = {
        :state => :inequal,
        :elements => {
          :old => {:value => ["foo", "bar"], :type => :array, :size => 2},
          :new => {:value => ["foo", "baz"], :type => :array, :size => 2},
          :common => {:value => nil, :type => :array, :size => 2}
        },
        :details => [
          [:equal, [
            {
              :state => :equal,
              :elements => {
                :old => {:value => "foo", :type => :string, :key => 0},
                :new => {:value => "foo", :type => :string, :key => 0},
                :common => {:value => "foo", :type => :string, :key => 0}
              }
            }
          ]],
          [:inequal, [
            {
              :state => :inequal,
              :elements => {
                :old => {:value => "bar", :type => :string, :key => 1},
                :new => {:value => "baz", :type => :string, :key => 1},
                :common => {:value => nil, :type => :string, :key => 1}
              }
            }
          ]]
        ]
      }
      described_class.report(change, to: stdout)
      msg = <<EOT
Error: Arrays of same size but with differing elements.

Expected: ["foo", "bar"]
Got: ["foo", "baz"]

Details:
- *[1]: Differing strings.
  - Expected: "bar"
  - Got: "baz"
EOT
      stdout.string.should == msg
    end

    specify "deep arrays of same size but differing elements" do
      change = {
        :state => :inequal,
        :elements => {
          :old => {:value => [["foo", "bar"], ["baz", "quux"]], :type => :array, :size => 2},
          :new => {:value => [["foo", "biz"], ["baz", "quarks"]], :type => :array, :size => 2},
          :common => {:value => nil, :type => :array, :size => 2}
        },
        :details => [
          [:inequal, [
            {
              :state => :inequal,
              :elements => {
                :old => {:value => ["foo", "bar"], :type => :array, :size => 2, :key => 0},
                :new => {:value => ["foo", "biz"], :type => :array, :size => 2, :key => 0},
                :common => {:value => nil, :type => :array, :size => 2, :key => 0}
              },
              :details => [
                [:equal, [
                  {
                    :state => :equal,
                    :elements => {
                      :old => {:value => "foo", :type => :string, :key => 0},
                      :new => {:value => "foo", :type => :string, :key => 0},
                      :common => {:value => "foo", :type => :string, :key => 0}
                    }
                  }
                ]],
                [:inequal, [
                  {
                    :state => :inequal,
                    :elements => {
                      :old => {:value => "bar", :type => :string, :key => 1},
                      :new => {:value => "biz", :type => :string, :key => 1},
                      :common => {:value => "biz", :type => :string, :key => 1}
                    }
                  }
                ]]
              ]
            }
          ]],
          [:equal, [
            {
              :state => :inequal,
              :elements => {
                :old => {:value => ["baz", "quux"], :type => :array, :size => 2, :key => 1},
                :new => {:value => ["baz", "quarks"], :type => :array, :size => 2, :key => 1},
                :common => {:value => nil, :type => :array, :size => 2, :key => 1}
              },
              :details => [
                [:equal, [
                  {
                    :state => :equal,
                    :elements => {
                      :old => {:value => "baz", :type => :string, :key => 0},
                      :new => {:value => "baz", :type => :string, :key => 0},
                      :common => {:value => "baz", :type => :string, :key => 0}
                    }
                  }
                ]],
                [:inequal, [
                  {
                    :state => :inequal,
                    :elements => {
                      :old => {:value => "quux", :type => :string, :key => 1},
                      :new => {:value => "quarks", :type => :string, :key => 1},
                      :common => {:value => nil, :type => :string, :key => 1}
                    }
                  }
                ]]
              ]
            }
          ]]
        ]
      }
      described_class.report(change, to: stdout)
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
      stdout.string.should == msg
    end

    specify "deeper arrays with differing elements" do
      change = {
        :state => :inequal,
        :elements => {
          :old => {
            :value => [
              "foo",
              ["bar", ["baz", "quux"]],
              "ying",
              ["blargh", "zing", "fooz", ["raz", ["vermouth"]]]
            ],
            :type => :array,
            :size => 4
          },
          :new => {
            :value => [
              "foz",
              "bar",
              "ying",
              ["blargh", "gragh", 1, ["raz", ["ralston"]]]
            ],
            :type => :array,
            :size => 4
          },
          :common => {
            :value => nil,
            :type => :array,
            :size => 4
          }
        },
        :details => [
          [:inequal, [
            {
              :state => :inequal,
              :elements => {
                :old => {:value => "foo", :type => :string, :key => 0},
                :new => {:value => "foz", :type => :string, :key => 0},
                :common => {:value => nil, :type => :string, :key => 0}
              }
            }
          ]],
          [:inequal, [
            {
              :state => :inequal,
              :elements => {
                :old => {:value => ["bar", ["baz", "quux"]], :type => :array, :size => 2, :key => 1},
                :new => {:value => "bar", :type => :string, :key => 1},
                :common => {:value => nil, :type => nil, :key => 1}
              }
            }
          ]],
          [:equal, [
            {
              :state => :equal,
              :elements => {
                :old => {:value => "ying", :type => :string, :key => 2},
                :new => {:value => "ying", :type => :string, :key => 2},
                :common => {:value => "ying", :type => :string, :key => 2}
              }
            }
          ]],
          [:inequal, [
            {
              :state => :inequal,
              :elements => {
                :old => {
                  :value => ["blargh", "zing", "fooz", ["raz", ["vermouth"]]],
                  :type => :array,
                  :size => 4,
                  :key => 3
                },
                :new => {
                  :value => ["blargh", "gragh", 1, ["raz", ["ralston"]]],
                  :type => :array,
                  :size => 4,
                  :key => 3
                },
                :common => {
                  :value => nil,
                  :type => :array,
                  :size => 4,
                  :key => 3
                }
              },
              :details => [
                [:equal, [
                  {
                    :state => :equal,
                    :elements => {
                      :old => {:value => "blargh", :type => :string, :key => 0},
                      :new => {:value => "blargh", :type => :string, :key => 0},
                      :common => {:value => "blargh", :type => :string, :key => 0}
                    }
                  }
                ]],
                [:inequal, [
                  {
                    :state => :inequal,
                    :elements => {
                      :old => {:value => "zing", :type => :string, :key => 1},
                      :new => {:value => "gragh", :type => :string, :key => 1},
                      :common => {:value => nil, :type => :string, :key => 1}
                    }
                  }
                ]],
                [:inequal, [
                  {
                    :state => :inequal,
                    :elements => {
                      :old => {:value => "fooz", :type => :string, :key => 2},
                      :new => {:value => 1, :type => :number, :key => 2},
                      :common => {:value => nil, :type => nil, :key => 2}
                    }
                  }
                ]],
                [:equal, [
                  {
                    :state => :inequal,
                    :elements => {
                      :old => {:value => ["raz", ["vermouth"]], :type => :array, :size => 2, :key => 3},
                      :new => {:value => ["raz", ["ralston"]], :type => :array, :size => 2, :key => 3},
                      :common => {:value => nil, :type => :array, :size => 2, :key => 3}
                    },
                    :details => [
                      [:equal, [
                        {
                          :state => :equal,
                          :elements => {
                            :old => {:value => "raz", :type => :string, :key => 0},
                            :new => {:value => "raz", :type => :string, :key => 0},
                            :common => {:value => "raz", :type => :string, :key => 0}
                          }
                        }
                      ]],
                      [:inequal, [
                        {
                          :state => :inequal,
                          :elements => {
                            :old => {:value => ["vermouth"], :type => :array, :size => 1, :key => 1},
                            :new => {:value => ["ralston"], :type => :array, :size => 1, :key => 1},
                            :common => {:value => nil, :type => :array, :size => 1, :key => 1}
                          },
                          :details => [
                            [:inequal, [
                              {
                                :state => :inequal,
                                :elements => {
                                  :old => {:value => "vermouth", :type => :string, :key => 0},
                                  :new => {:value => "ralston", :type => :string, :key => 0},
                                  :common => {:value => nil, :type => :string, :key => 0}
                                }
                              }
                            ]]
                          ]
                        }
                      ]]
                    ]
                  }
                ]]
              ]
            }
          ]]
        ]
      }
      described_class.report(change, to: stdout)
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
      stdout.string.should == msg
    end

    specify "shallow arrays with surplus elements that appear at the beginning" do
      change = {
        :state => :inequal,
        :elements => {
          :old => {:value => ["foo", "bar"], :type => :array, :size => 2},
          :new => {:value => ["baz", "quux", "foo", "bar"], :type => :array, :size => 4},
          :common => {:value => nil, :type => :array, :size => nil}
        },
        :details => [
          [:surplus, [
            {
              :state => :surplus,
              :elements => {
                :old => nil,
                :new => {:value => "baz", :type => :string, :key => 0},
                :common => nil
              }
            },
            {
              :state => :surplus,
              :elements => {
                :old => nil,
                :new => {:value => "quux", :type => :string, :key => 1},
                :common => nil
              }
            }
          ]],
          [:equal, [
            {
              :state => :equal,
              :elements => {
                :old => {:value => "foo", :type => :string, :key => 0},
                :new => {:value => "foo", :type => :string, :key => 2},
                :common => {:value => "foo", :type => :string, :key => nil}
              },
            }
          ]],
          [:equal, [
            {
              :state => :equal,
              :elements => {
                :old => {:value => "bar", :type => :string, :key => 1},
                :new => {:value => "bar", :type => :string, :key => 3},
                :common => {:value => "bar", :type => :string, :key => nil}
              }
            }
          ]]
        ]
      }
      described_class.report(change, to: stdout)
      msg = <<EOT
Error: Arrays of differing size (no differing elements).

Expected: ["foo", "bar"]
Got: ["baz", "quux", "foo", "bar"]

Details:
- *[? -> 0..1]: "baz", "quux" unexpectedly found before "foo".
EOT
      stdout.string.should == msg
    end

    specify "shallow arrays with surplus elements that appear at the end" do
      change = {
        :state => :inequal,
        :elements => {
          :old => {:value => ["foo", "bar"], :type => :array, :size => 2},
          :new => {:value => ["foo", "bar", "baz", "quux"], :type => :array, :size => 4},
          :common => {:value => nil, :type => :array, :size => nil}
        },
        :details => [
          [:equal, [
            {
              :state => :equal,
              :elements => {
                :old => {:value => "foo", :type => :string, :key => 0},
                :new => {:value => "foo", :type => :string, :key => 0},
                :common => {:value => "foo", :type => :string, :key => 0}
              },
            }
          ]],
          [:equal, [
            {
              :state => :equal,
              :elements => {
                :old => {:value => "bar", :type => :string, :key => 1},
                :new => {:value => "bar", :type => :string, :key => 1},
                :common => {:value => "bar", :type => :string, :key => 1}
              }
            }
          ]],
          [:surplus, [
            {
              :state => :surplus,
              :elements => {
                :new => {:value => "baz", :type => :string, :key => 2},
                :common => nil
              }
            },
            {
              :state => :surplus,
              :elements => {
                :old => nil,
                :new => {:value => "quux", :type => :string, :key => 3},
                :common => nil
              }
            }
          ]]
        ]
      }
      described_class.report(change, to: stdout)
      msg = <<EOT
Error: Arrays of differing size (no differing elements).

Expected: ["foo", "bar"]
Got: ["foo", "bar", "baz", "quux"]

Details:
- *[? -> 2..3]: "baz", "quux" unexpectedly found after "bar".
EOT
      stdout.string.should == msg
    end

    specify "shallow arrays with surplus elements that appear after a changed element" do
      change = {
        :state => :inequal,
        :elements => {
          :old => {:value => ["foo", "bar", "baz"], :type => :array, :size => 3},
          :new => {:value => ["foo", "bar", "buzz", "quux", "blargh"], :type => :array, :size => 5},
          :common => {:value => nil, :type => :array, :size => nil}
        },
        :details => [
          [:equal, [
            {
              :state => :equal,
              :elements => {
                :old => {:value => "foo", :type => :string, :key => 0},
                :new => {:value => "foo", :type => :string, :key => 0},
                :common => {:value => "foo", :type => :string, :key => 0}
              },
            }
          ]],
          [:equal, [
            {
              :state => :equal,
              :elements => {
                :old => {:value => "bar", :type => :string, :key => 1},
                :new => {:value => "bar", :type => :string, :key => 1},
                :common => {:value => "bar", :type => :string, :key => 1}
              }
            }
          ]],
          [:inequal, [
            {
              :state => :inequal,
              :elements => {
                :old => {:value => "baz", :type => :string, :key => 2},
                :new => {:value => "buzz", :type => :string, :key => 2},
                :common => {:value => nil, :type => :string, :key => 2}
              }
            }
          ]],
          [:surplus, [
            {
              :state => :surplus,
              :elements => {
                :old => nil,
                :new => {:value => "quux", :type => :string, :key => 3},
                :common => nil
              }
            },
            {
              :state => :surplus,
              :elements => {
                :old => nil,
                :new => {:value => "blargh", :type => :string, :key => 4},
                :common => nil
              }
            }
          ]]
        ]
      }
      described_class.report(change, to: stdout)
      msg = <<EOT
Error: Arrays of differing size and elements.

Expected: ["foo", "bar", "baz"]
Got: ["foo", "bar", "buzz", "quux", "blargh"]

Details:
- *[2]: Differing strings.
  - Expected: "baz"
  - Got: "buzz"
- *[? -> 3..4]: "quux", "blargh" unexpectedly found after "baz" (now "buzz").
EOT
      stdout.string.should == msg
    end

    specify "shallow arrays with missing elements that were removed at the beginning" do
      change = {
        :state => :inequal,
        :elements => {
          :old => {:value => ["baz", "quux", "foo", "bar"], :type => :array, :size => 4},
          :new => {:value => ["foo", "bar"], :type => :array, :size => 2},
          :common => {:value => nil, :type => :array, :size => nil}
        },
        :details => [
          [:missing, [
            {
              :state => :missing,
              :elements => {
                :old => {:value => "baz", :type => :string, :key => 0},
                :new => nil,
                :common => nil
              }
            },
            {
              :state => :missing,
              :elements => {
                :old => {:value => "quux", :type => :string, :key => 1},
                :new => nil,
                :common => nil
              }
            }
          ]],
          [:equal, [
            {
              :state => :equal,
              :elements => {
                :old => {:value => "foo", :type => :string, :key => 2},
                :new => {:value => "foo", :type => :string, :key => 0},
                :common => {:value => "foo", :type => :string, :key => nil}
              },
            }
          ]],
          [:equal, [
            {
              :state => :equal,
              :elements => {
                :old => {:value => "bar", :type => :string, :key => 3},
                :new => {:value => "bar", :type => :string, :key => 1},
                :common => {:value => "bar", :type => :string, :key => nil}
              }
            }
          ]]
        ]
      }
      described_class.report(change, to: stdout)
      msg = <<EOT
Error: Arrays of differing size (no differing elements).

Expected: ["baz", "quux", "foo", "bar"]
Got: ["foo", "bar"]

Details:
- *[0..1 -> ?]: "baz", "quux" unexpectedly missing from before "foo".
EOT
      stdout.string.should == msg
    end

    specify "shallow arrays with missing elements that were removed at the end" do
      change = {
        :state => :inequal,
        :elements => {
          :old => {:value => ["foo", "bar", "baz", "quux"], :type => :array, :size => 4},
          :new => {:value => ["foo", "bar"], :type => :array, :size => 2},
          :common => {:value => nil, :type => :array, :size => nil}
        },
        :details => [
          [:equal, [
            {
              :state => :equal,
              :elements => {
                :old => {:value => "foo", :type => :string, :key => 0},
                :new => {:value => "foo", :type => :string, :key => 0},
                :common => {:value => "foo", :type => :string, :key => 0}
              },
            }
          ]],
          [:equal, [
            {
              :state => :equal,
              :elements => {
                :old => {:value => "bar", :type => :string, :key => 1},
                :new => {:value => "bar", :type => :string, :key => 1},
                :common => {:value => "bar", :type => :string, :key => 1}
              }
            }
          ]],
          [:missing, [
            {
              :state => :missing,
              :elements => {
                :old => {:value => "baz", :type => :string, :key => 2},
                :new => nil,
                :common => nil
              }
            },
            {
              :state => :missing,
              :elements => {
                :old => {:value => "quux", :type => :string, :key => 3},
                :new => nil,
                :common => nil
              }
            }
          ]]
        ]
      }
      described_class.report(change, to: stdout)
      msg = <<EOT
Error: Arrays of differing size (no differing elements).

Expected: ["foo", "bar", "baz", "quux"]
Got: ["foo", "bar"]

Details:
- *[2..3 -> ?]: "baz", "quux" unexpectedly missing from after "bar".
EOT
      stdout.string.should == msg
    end

    specify "shallow arrays with missing elements that were removed after a changed element" do
      change = {
        :state => :inequal,
        :elements => {
          :old => {:value => ["foo", "bar", "baz", "quux", "blargh"], :type => :array, :size => 5},
          :new => {:value => ["foo", "bar", "buzz"], :type => :array, :size => 3},
          :common => {:value => nil, :type => :array, :size => nil}
        },
        :details => [
          [:equal, [
            {
              :state => :equal,
              :elements => {
                :old => {:value => "foo", :type => :string, :key => 0},
                :new => {:value => "foo", :type => :string, :key => 0},
                :common => {:value => "foo", :type => :string, :key => 0}
              },
            }
          ]],
          [:equal, [
            {
              :state => :equal,
              :elements => {
                :old => {:value => "bar", :type => :string, :key => 1},
                :new => {:value => "bar", :type => :string, :key => 1},
                :common => {:value => "bar", :type => :string, :key => 1}
              }
            }
          ]],
          [:inequal, [
            {
              :state => :inequal,
              :elements => {
                :old => {:value => "baz", :type => :string, :key => 2},
                :new => {:value => "buzz", :type => :string, :key => 2},
                :common => {:value => nil, :type => :string, :key => 2}
              }
            }
          ]],
          [:missing, [
            {
              :state => :missing,
              :elements => {
                :old => {:value => "quux", :type => :string, :key => 3},
                :new => nil,
                :common => nil
              }
            },
            {
              :state => :missing,
              :elements => {
                :old => {:value => "blargh", :type => :string, :key => 4},
                :new => nil,
                :common => nil
              }
            }
          ]]
        ]
      }
      described_class.report(change, to: stdout)
      msg = <<EOT
Error: Arrays of differing size and elements.

Expected: ["foo", "bar", "baz", "quux", "blargh"]
Got: ["foo", "bar", "buzz"]

Details:
- *[2]: Differing strings.
  - Expected: "baz"
  - Got: "buzz"
- *[3..4 -> ?]: "quux", "blargh" unexpectedly missing from after "baz" (now "buzz").
EOT
      stdout.string.should == msg
    end

    specify "deep arrays with surplus elements" do
      change = {
        :state => :inequal,
        :elements => {
          :old => {:value => ["foo", ["bar", "baz"], "ying"], :type => :array, :size => 3},
          :new => {:value => ["foo", ["bar", "quux", "zing", "baz", "blargh"], "yang", "ying"], :type => :array, :size => 3},
          :common => {:value => nil, :type => :array, :size => 3}
        },
        :details => [
          [:equal, [
            {
              :state => :equal,
              :elements => {
                :old => {:value => "foo", :type => :string, :key => 0},
                :new => {:value => "foo", :type => :string, :key => 0},
                :common => {:value => "foo", :type => :string, :key => 0}
              }
            }
          ]],
          [:inequal, [
            {
              :state => :inequal,
              :elements => {
                :old => {:value => ["bar", "baz"], :type => :array, :key => 1, :size => 2},
                :new => {:value => ["bar", "quux", "zing", "baz", "blargh"], :type => :array, :key => 1, :size => 5},
                :common => {:value => nil, :type => :array, :key => 1, :size => nil}
              },
              :details => [
                [:equal, [
                  {
                    :state => :equal,
                    :elements => {
                      :old => {:value => "bar", :type => :string, :key => 0},
                      :new => {:value => "bar", :type => :string, :key => 0},
                      :common => {:value => "bar", :type => :string, :key => 0}
                    }
                  }
                ]],
                [:surplus, [
                  {
                    :state => :surplus,
                    :elements => {
                      :old => nil,
                      :new => {:value => "quux", :type => :string, :key => 1},
                      :common => nil
                    }
                  },
                  {
                    :state => :surplus,
                    :elements => {
                      :old => nil,
                      :new => {:value => "zing", :type => :string, :key => 2},
                      :common => nil
                    }
                  }
                ]],
                [:equal, [
                  {
                    :state => :equal,
                    :elements => {
                      :old => {:value => "baz", :type => :string, :key => 1},
                      :new => {:value => "baz", :type => :string, :key => 3},
                      :common => {:value => "baz", :type => :string, :key => nil}
                    }
                  }
                ]],
                [:surplus, [
                  {
                    :state => :surplus,
                    :elements => {
                      :old => nil,
                      :new => {:value => "blargh", :type => :string, :key => 4},
                      :common => nil
                    }
                  }
                ]]
              ]
            }
          ]],
          [:surplus, [
            {
              :state => :surplus,
              :elements => {
                :old => nil,
                :new => {:value => "yang", :type => :string, :key => 2},
                :common => nil
              }
            }
          ]],
          [:equal, [
            {
              :state => :equal,
              :elements => {
                :old => {:value => "ying", :type => :string, :key => 2},
                :new => {:value => "ying", :type => :string, :key => 3},
                :common => {:value => "ying", :type => :string, :key => nil}
              }
            }
          ]]
        ]
      }
      described_class.report(change, to: stdout)
      msg = <<EOT
Error: Arrays of same size but with differing elements.

Expected: ["foo", ["bar", "baz"], "ying"]
Got: ["foo", ["bar", "quux", "zing", "baz", "blargh"], "yang", "ying"]

Details:
- *[1]: Arrays of differing size (no differing elements).
  - *[? -> 1..2]: "quux", "zing" unexpectedly found after "bar".
  - *[? -> 4]: "blargh" unexpectedly found after "baz".
- *[? -> 2]: "yang" unexpectedly found after ["bar", "baz"] (now ["bar", "quux", "zing", "baz", "blargh"]).
EOT
      stdout.string.should == msg
    end

    specify "deep arrays with missing elements" do
      change = {
        :state => :inequal,
        :elements => {
          :old => {:value => ["foo", ["bar", "baz", "quux", "blargh"], "ying"], :type => :array, :size => 3},
          :new => {:value => ["foo", ["bar", "baz"], "ying"], :type => :array, :size => 3},
          :common => {:value => nil, :type => :array, :size => 3}
        },
        :details => [
          [:equal, [
            {
              :state => :equal,
              :elements => {
                :old => {:value => "foo", :type => :string, :key => 0},
                :new => {:value => "foo", :type => :string, :key => 0},
                :common => {:value => "foo", :type => :string, :key => 0}
              }
            }
          ]],
          [:inequal, [
            {
              :state => :inequal,
              :elements => {
                :old => {:value => ["bar", "baz", "quux", "blargh"], :type => :array, :size => 4, :key => 1},
                :new => {:value => ["bar", "baz"], :type => :array, :size => 2, :key => 1},
                :common => {:value => nil, :type => :array, :size => nil, :key => 1}
              },
              :details => [
                [:equal, [
                  {
                    :state => :equal,
                    :elements => {
                      :old => {:value => "bar", :type => :string, :key => 0},
                      :new => {:value => "bar", :type => :string, :key => 0},
                      :common => {:value => "bar", :type => :string, :key => 0}
                    }
                  }
                ]],
                [:equal, [
                  {
                    :state => :equal,
                    :elements => {
                      :old => {:value => "baz", :type => :string, :key => 1},
                      :new => {:value => "baz", :type => :string, :key => 1},
                      :common => {:value => "baz", :type => :string, :key => 1}
                    }
                  }
                ]],
                [:missing, [
                  {
                    :state => :missing,
                    :elements => {
                      :old => {:value => "quux", :type => :string, :key => 2},
                      :new => nil,
                      :common => nil
                    }
                  },
                  {
                    :state => :missing,
                    :elements => {
                      :old => {:value => "blargh", :type => :string, :key => 3},
                      :new => nil,
                      :common => nil
                    }
                  }
                ]]
              ]
            }
          ]],
          [:equal, [
            {
              :state => :equal,
              :elements => {
                :old => {:value => "ying", :type => :string, :key => 2},
                :new => {:value => "ying", :type => :string, :key => 2},
                :common => {:value => "ying", :type => :string, :key => 2}
              }
            }
          ]]
        ]
      }
      described_class.report(change, to: stdout)
      msg = <<EOT
Error: Arrays of same size but with differing elements.

Expected: ["foo", ["bar", "baz", "quux", "blargh"], "ying"]
Got: ["foo", ["bar", "baz"], "ying"]

Details:
- *[1]: Arrays of differing size (no differing elements).
  - *[2..3 -> ?]: "quux", "blargh" unexpectedly missing from after "baz".
EOT
      stdout.string.should == msg
    end

    # TODO: Need to fix this one in more detail
    specify "deeper arrays with variously differing arrays" do
      change = {
        :state => :inequal,
        :elements => {
          :old => {
            :value => [
              "foo",
              "bar",
              ["baz", "quux"],
              "ying",
              ["blargh", "zing", "fooz", ["raz", ["vermouth", "eee", "ffff"]]]
            ],
            :type => :array,
            :size => 4
          },
          :new => {
            :value => [
              "foz",
              "bar",
              "ying",
              ["xyzzy", "blargh", "zing", 1, ["raz", ["ralston"]], ["foreal", ["zap"]]]
            ],
            :type => :array,
            :size => 4
          },
          :common => {
            :value => nil,
            :type => :array,
            :size => 4
          }
        },
        :details => [
          [:inequal, [
            {
              :state => :inequal,
              :elements => {
                :old => {:value => "foo", :type => :string, :key => 0},
                :new => {:value => "foz", :type => :string, :key => 0},
                :common => {:value => nil, :type => :string, :key => 0}
              }
            }
          ]],
          [:equal, [
            {
              :state => :equal,
              :elements => {
                :old => {:value => "bar", :type => :string, :key => 1},
                :new => {:value => "bar", :type => :string, :key => 1},
                :common => {:value => "bar", :type => :string, :key => 1}
              }
            }
          ]],
          [:missing, [
            {
              :state => :missing,
              :elements => {
                :old => {:value => ["baz", "quux"], :type => :array, :size => 2, :key => 2},
                :new => nil,
                :common => nil
              }
            }
          ]],
          [:equal, [
            {
              :state => :equal,
              :elements => {
                :old => {:value => "ying", :type => :string, :key => 3},
                :new => {:value => "ying", :type => :string, :key => 2},
                :common => {:value => "ying", :type => :string, :key => nil}
              }
            }
          ]],
          [:inequal, [
            {
              :state => :inequal,
              :elements => {
                :old => {
                  :value => ["blargh", "zing", "fooz", ["raz", ["vermouth", "eee", "ffff"]]],
                  :type => :array,
                  :size => 4,
                  :key => 4
                },
                :new => {
                  :value => ["xyzzy", "blargh", "zing", 1, ["raz", ["ralston"]], ["foreal", ["zap"]]],
                  :type => :array,
                  :size => 5,
                  :key => 3
                },
                :common => {
                  :value => nil,
                  :type => :array,
                  :size => nil,
                  :key => nil
                }
              },
              :details => [
                [:surplus, [
                  {
                    :state => :surplus,
                    :elements => {
                      :old => nil,
                      :new => {:value => "xyzzy", :type => :string, :key => 0},
                      :common => nil
                    }
                  }
                ]],
                [:equal, [
                  {
                    :state => :equal,
                    :elements => {
                      :old => {:value => "blargh", :type => :string, :key => 0},
                      :new => {:value => "blargh", :type => :string, :key => 1},
                      :common => {:value => "blargh", :type => :string, :key => nil}
                    }
                  }
                ]],
                [:equal, [
                  {
                    :state => :equal,
                    :elements => {
                      :old => {:value => "zing", :type => :string, :key => 1},
                      :new => {:value => "zing", :type => :string, :key => 2},
                      :common => {:value => nil, :type => :string, :key => nil}
                    }
                  }
                ]],
                [:inequal, [
                  {
                    :state => :inequal,
                    :elements => {
                      :old => {:value => "fooz", :type => :string, :key => 2},
                      :new => {:value => 1, :type => :number, :key => 3},
                      :common => {:value => nil, :type => nil, :key => nil}
                    }
                  }
                ]],
                [:inequal, [
                  {
                    :state => :inequal,
                    :elements => {
                      :old => {:value => ["raz", ["vermouth", "eee", "ffff"]], :type => :array, :size => 2, :key => 3},
                      :new => {:value => ["raz", ["ralston"]], :type => :array, :size => 2, :key => 4},
                      :common => {:value => nil, :type => :array, :size => 2, :key => nil}
                    },
                    :details => [
                      [:equal, [
                        {
                          :state => :equal,
                          :elements => {
                            :old => {:value => "raz", :type => :string, :key => 0},
                            :new => {:value => "raz", :type => :string, :key => 0},
                            :common => {:value => "raz", :type => :string, :key => 0}
                          }
                        },
                      ]],
                      [:inequal, [
                        {
                          :state => :inequal,
                          :elements => {
                            :old => {:value => ["vermouth", "eee", "ffff"], :type => :array, :size => 3, :key => 1},
                            :new => {:value => ["ralston"], :type => :array, :size => 1, :key => 1},
                            :common => {:value => nil, :type => :array, :size => nil, :key => 1}
                          },
                          :details => [
                            # Deleting all elements and then adding one back counts as a wholesale replacement
                            [:missing, [
                              {
                                :state => :missing,
                                :elements => {
                                  :old => {:value => "vermouth", :type => :string, :key => 0},
                                  :new => nil,
                                  :common => nil
                                }
                              },
                              {
                                :state => :missing,
                                :elements => {
                                  :old => {:value => "eee", :type => :string, :key => 1},
                                  :new => nil,
                                  :common => nil
                                }
                              },
                              {
                                :state => :missing,
                                :elements => {
                                  :old => {:value => "ffff", :type => :string, :key => 2},
                                  :new => nil,
                                  :common => nil
                                }
                              }
                            ]],
                            [:surplus, [
                              {
                                :state => :surplus,
                                :elements => {
                                  :old => nil,
                                  :new => {:value => "ralston", :type => :string, :key => 0},
                                  :common => nil
                                }
                              }
                            ]]
                          ]
                        }
                      ]]
                    ]
                  }
                ]],
                [:surplus, [
                  {
                    :state => :surplus,
                    :elements => {
                      :old => nil,
                      :new => {:value => ["foreal", ["zap"]], :type => :array, :size => 2, :key => 5},
                      :common => nil
                    }
                  }
                ]]
              ]
            }
          ]]
        ]
      }
      described_class.report(change, to: stdout)
      msg = <<EOT
Error: Arrays of same size but with differing elements.

Expected: ["foo", "bar", ["baz", "quux"], "ying", ["blargh", "zing", "fooz", ["raz", ["vermouth", "eee", "ffff"]]]]
Got: ["foz", "bar", "ying", ["xyzzy", "blargh", "zing", 1, ["raz", ["ralston"]], ["foreal", ["zap"]]]]

Details:
- *[0]: Differing strings.
  - Expected: "foo"
  - Got: "foz"
- *[2 -> ?]: ["baz", "quux"] unexpectedly missing from after "bar".
- *[4 -> 3]: Arrays of differing size and elements.
  - *[? -> 0]: "xyzzy" unexpectedly found before "blargh".
  - *[2 -> 3]: Values of differing type.
    - Expected: "fooz"
    - Got: 1
  - *[3 -> 4]: Arrays of same size but with differing elements.
    - *[1]: Differing arrays.
      - Expected: ["vermouth", "eee", "ffff"]
      - Got: ["ralston"]
  - *[? -> 5]: ["foreal", ["zap"]] unexpectedly found after ["raz", ["ralston"]].
EOT
      stdout.string.should == msg
    end

    specify "shallow hashes of same size but differing elements" do
      change = {
        :state => :inequal,
        :elements => {
          :old => {:value => {"foo" => "bar", "baz" => "quux"}, :type => :hash, :size => 2},
          :new => {:value => {"foo" => "bar", "baz" => "quarx"}, :type => :hash, :size => 2},
          :common => {:value => nil, :type => :hash, :size => 2}
        },
        :details => [
          [:equal, [
            {
              :state => :equal,
              :elements => {
                :old => {:value => "bar", :type => :string, :key => "foo"},
                :new => {:value => "bar", :type => :string, :key => "foo"},
                :common => {:value => "bar", :type => :string, :key => "foo"}
              }
            }
          ]],
          [:inequal, [
            {
              :state => :inequal,
              :elements => {
                :old => {:value => "quux", :type => :string, :key => "baz"},
                :new => {:value => "quarx", :type => :string, :key => "baz"},
                :common => {:value => nil, :type => :string, :key => "baz"}
              }
            }
          ]]
        ]
      }
      described_class.report(change, to: stdout)
      msg = <<EOT
Error: Hashes of same size but with differing elements.

Expected: {"foo"=>"bar", "baz"=>"quux"}
Got: {"foo"=>"bar", "baz"=>"quarx"}

Details:
- *["baz"]: Differing strings.
  - Expected: "quux"
  - Got: "quarx"
EOT
      stdout.string.should == msg
    end

    specify "deep hashes of same size but differing elements" do
      change = {
        :state => :inequal,
        :elements => {
          :old => {
            :value => {"one" => {"foo" => "bar", "baz" => "quux"}, :two => {"ying" => 1, "zing" => :zang}},
            :type => :hash,
            :size => 2
          },
          :new => {
            :value => {"one" => {"foo" => "boo", "baz" => "quux"}, :two => {"ying" => "yang", "zing" => :bananas}},
            :type => :hash,
            :size => 2
          },
          :common => {
            :value => nil,
            :type => :hash,
            :size => 2
          }
        },
        :details => [
          [:inequal, [
            {
              :state => :inequal,
              :elements => {
                :old => {:value => {"foo" => "bar", "baz" => "quux"}, :type => :hash, :size => 2, :key => "one"},
                :new => {:value => {"foo" => "boo", "baz" => "quux"}, :type => :hash, :size => 2, :key => "one"},
                :common => {:value => nil, :type => :hash, :size => 2, :key => "one"}
              },
              :details => [
                [:inequal, [
                  {
                    :state => :inequal,
                    :elements => {
                      :old => {:value => "bar", :type => :string, :key => "foo"},
                      :new => {:value => "boo", :type => :string, :key => "foo"},
                      :common => {:value => "boo", :type => :string, :key => "foo"}
                    }
                  }
                ]],
                [:equal, [
                  {
                    :state => :equal,
                    :elements => {
                      :old => {:value => "quux", :type => :string, :key => "baz"},
                      :new => {:value => "quux", :type => :string, :key => "baz"},
                      :common => {:value => "quux", :type => :string, :key => "baz"}
                    }
                  }
                ]]
              ]
            }
          ]],
          [:two, [
            {
              :state => :inequal,
              :elements => {
                :old => {:value => {"ying" => 1, "zing" => :zang}, :type => :hash, :size => 2, :key => :two},
                :new => {:value => {"ying" => "yang", "zing" => :bananas}, :type => :hash, :size => 2, :key => :two},
                :common => {:value => nil, :type => :hash, :size => 2, :key => :two}
              },
              :details => [
                [:inequal, [
                  {
                    :state => :inequal,
                    :elements => {
                      :old => {:value => 1, :type => :number, :key => "ying"},
                      :new => {:value => "yang", :type => :string, :key => "ying"},
                      :common => {:value => nil, :type => nil, :key => "ying"}
                    }
                  }
                ]],
                ["zing", [
                  {
                    :state => :inequal,
                    :elements => {
                      :old => {:value => :zang, :type => :symbol, :key => "zing"},
                      :new => {:value => :bananas, :type => :symbol, :key => "zing"},
                      :common => {:value => nil, :type => :symbol, :key => "zing"}
                    }
                  }
                ]]
              ]
            }
          ]]
        ]
      }
      described_class.report(change, to: stdout)
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
      stdout.string.should == msg
    end

    specify "deeper hashes with differing elements" do
      change = {
        :state => :inequal,
        :elements => {
          :old => {
            :value => {
              "foo" => {1 => {"baz" => {"quux" => 2}, "foz" => {"fram" => "frazzle"}}},
              "biz" => {:fiz => "gram", 1 => {2 => :sym}}
            },
            :type => :hash,
            :size => 2
          },
          :new => {
            :value => {
              "foo" => {1 => {"baz" => "quarx", "foz" => {"fram" => "razzle"}}},
              "biz" => {:fiz => "graeme", 1 => 3}
            },
            :type => :hash,
            :size => 2
          },
          :common => {
            :value => nil,
            :type => :hash,
            :size => 2
          }
        },
        :details => [
          [:inequal, [
            {
              :state => :inequal,
              :elements => {
                :old => {
                  :value => {1 => {"baz" => {"quux" => 2}, "foz" => {"fram" => "frazzle"}}},
                  :type => :hash,
                  :size => 1,
                  :key => "foo"
                },
                :new => {
                  :value => {1 => {"baz" => "quarx", "foz" => {"fram" => "razzle"}}},
                  :type => :hash,
                  :size => 1,
                  :key => "foo"
                },
                :common => {
                  :value => nil,
                  :type => :hash,
                  :size => 1,
                  :key => "foo"
                },
              },
              :details => [
                [:inequal, [
                  {
                    :state => :inequal,
                    :elements => {
                      :old => {
                        :value => {"baz" => {"quux" => 2}, "foz" => {"fram" => "frazzle"}},
                        :type => :hash,
                        :size => 2,
                        :key => 1
                      },
                      :new => {
                        :value => {"baz" => "quarx", "foz" => {"fram" => "razzle"}},
                        :type => :hash,
                        :size => 2,
                        :key => 1
                      },
                      :common => {
                        :value => nil,
                        :type => :hash,
                        :size => 2,
                        :key => 1
                      }
                    },
                    :details => [
                      [:inequal, [
                        {
                          :state => :inequal,
                          :elements => {
                            :old => {:value => {"quux" => 2}, :type => :hash, :size => 1, :key => "baz"},
                            :new => {:value => "quarx", :type => :string, :key => "baz"},
                            :common => {:value => nil, :type => nil, :key => "baz"}
                          }
                        }
                      ]],
                      [:inequal, [
                        {
                          :state => :inequal,
                          :elements => {
                            :old => {:value => {"fram" => "frazzle"}, :type => :hash, :size => 1, :key => "foz"},
                            :new => {:value => {"fram" => "razzle"}, :type => :hash, :size => 1, :key => "foz"},
                            :common => {:value => nil, :type => :hash, :size => 1, :key => "foz"},
                          },
                          :details => [
                            [:inequal, [
                              {
                                :state => :inequal,
                                :elements => {
                                  :old => {:value => "frazzle", :type => :string, :key => "fram"},
                                  :new => {:value => "razzle", :type => :string, :key => "fram"},
                                  :common => {:value => nil, :type => :string, :key => "fram"}
                                }
                              }
                            ]]
                          ]
                        }
                      ]]
                    ]
                  }
                ]]
              ]
            }
          ]],
          [:inequal, [
            {
              :state => :inequal,
              :elements => {
                :old => {:value => {:fiz => "gram", 1 => {2 => :sym}}, :type => :hash, :size => 2, :key => "biz"},
                :new => {:value => {:fiz => "graeme", 1 => 3}, :type => :hash, :size => 2, :key => "biz"},
                :common => {:value => nil, :type => :hash, :size => 2, :key => "biz"},
              },
              :details => [
                [:inequal, [
                  {
                    :state => :inequal,
                    :elements => {
                      :old => {:value => "gram", :type => :string, :key => :fiz},
                      :new => {:value => "graeme", :type => :string, :key => :fiz},
                      :common => {:value => nil, :type => :string, :key => :fiz}
                    }
                  }
                ]],
                [:inequal, [
                  {
                    :state => :inequal,
                    :elements => {
                      :old => {:value => {2 => :sym}, :type => :hash, :size => 1, :key => 1},
                      :new => {:value => 3, :type => :number, :key => 1},
                      :common => {:value => nil, :type => nil, :key => 1}
                    }
                  }
                ]]
              ]
            }
          ]]
        ]
      }
      described_class.report(change, to: stdout)
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
      stdout.string.should == msg
    end

    specify "shallow hashes with surplus elements" do
      change = {
        :state => :inequal,
        :elements => {
          :old => {:value => {"foo" => "bar"}, :type => :hash, :size => 1},
          :new => {:value => {"foo" => "bar", "baz" => "quux", "ying" => "yang"}, :type => :hash, :size => 3},
          :common => {:value => nil, :type => :hash, :size => nil},
        },
        :details => [
          [:equal, [
            {
              :state => :equal,
              :elements => {
                :old => {:value => "bar", :type => :string, :key => "foo"},
                :new => {:value => "bar", :type => :string, :key => "foo"},
                :common => {:value => "bar", :type => :string, :key => "foo"}
              }
            }
          ]],
          [:surplus, [
            {
              :state => :surplus,
              :elements => {
                :old => nil,
                :new => {:value => "quux", :type => :string, :key => "baz"},
                :common => nil
              }
            }
          ]],
          [:surplus, [
            {
              :state => :surplus,
              :elements => {
                :old => nil,
                :new => {:value => "yang", :type => :string, :key => "ying"},
                :common => nil
              }
            }
          ]]
        ]
      }
      described_class.report(change, to: stdout)
      msg = <<EOT
Error: Hashes of differing size (no differing elements).

Expected: {"foo"=>"bar"}
Got: {"foo"=>"bar", "baz"=>"quux", "ying"=>"yang"}

Details:
- *[? -> "baz"]: "quux" unexpectedly found.
- *[? -> "ying"]: "yang" unexpectedly found.
EOT
      stdout.string.should == msg
    end

    specify "shallow hashes with missing elements" do
      change = {
        :state => :inequal,
        :elements => {
          :old => {:value => {"foo" => "bar", "baz" => "quux", "ying" => "yang"}, :type => :hash, :size => 3},
          :new => {:value => {"foo" => "bar"}, :type => :hash, :size => 1},
          :common => {:value => nil, :type => :hash, :size => nil}
        },
        :details => [
          [:equal, [
            {
              :state => :equal,
              :elements => {
                :old => {:value => "bar", :type => :string, :key => "foo"},
                :new => {:value => "bar", :type => :string, :key => "foo"},
                :common => {:value => "bar", :type => :string, :key => "foo"}
              }
            }
          ]],
          [:missing, [
            {
              :state => :missing,
              :elements => {
                :old => {:value => "quux", :type => :string, :key => "baz"},
                :new => nil,
                :common => nil
              }
            }
          ]],
          [:missing, [
            {
              :state => :missing,
              :elements => {
                :old => {:value => "yang", :type => :string, :key => "ying"},
                :new => nil,
                :common => nil
              }
            }
          ]]
        ]
      }
      described_class.report(change, to: stdout)
      msg = <<EOT
Error: Hashes of differing size (no differing elements).

Expected: {"foo"=>"bar", "baz"=>"quux", "ying"=>"yang"}
Got: {"foo"=>"bar"}

Details:
- *["baz" -> ?]: "quux" unexpectedly missing.
- *["ying" -> ?]: "yang" unexpectedly missing.
EOT
      stdout.string.should == msg
    end

    specify "deep hashes with surplus elements" do
      change = {
        :state => :inequal,
        :elements => {
          :old => {:value => {"one" => {"foo" => "bar"}}, :type => :hash, :size => 1},
          :new => {:value => {"one" => {"foo" => "bar", "baz" => "quux", "ying" => "yang"}}, :type => :hash, :size => 1},
          :common => {:value => nil, :type => :hash, :size => 1},
        },
        :details => [
          [:inequal, [
            {
              :state => :inequal,
              :elements => {
                :old => {:value => {"foo" => "bar"}, :type => :hash, :size => 1, :key => "one"},
                :new => {:value => {"foo" => "bar", "baz" => "quux", "ying" => "yang"}, :type => :hash, :size => 3, :key => "one"},
                :common => {:value => nil, :type => :hash, :size => nil, :key => "one"},
              },
              :details => [
                [:equal, [
                  {
                    :state => :equal,
                    :elements => {
                      :old => {:value => "bar", :type => :string, :key => "foo"},
                      :new => {:value => "bar", :type => :string, :key => "foo"},
                      :common => {:value => "bar", :type => :string, :key => "foo"}
                    }
                  }
                ]],
                [:surplus, [
                  {
                    :state => :surplus,
                    :elements => {
                      :old => nil,
                      :new => {:value => "quux", :type => :string, :key => "baz"},
                      :common => nil
                    }
                  }
                ]],
                [:surplus, [
                  {
                    :state => :surplus,
                    :elements => {
                      :old => nil,
                      :new => {:value => "yang", :type => :string, :key => "ying"},
                      :common => nil
                    }
                  }
                ]]
              ]
            }
          ]]
        ]
      }
      described_class.report(change, to: stdout)
      msg = <<EOT
Error: Hashes of same size but with differing elements.

Expected: {"one"=>{"foo"=>"bar"}}
Got: {"one"=>{"foo"=>"bar", "baz"=>"quux", "ying"=>"yang"}}

Details:
- *["one"]: Hashes of differing size (no differing elements).
  - *[? -> "baz"]: "quux" unexpectedly found.
  - *[? -> "ying"]: "yang" unexpectedly found.
EOT
      stdout.string.should == msg
    end

    specify "deep hashes with missing elements" do
      change = {
        :state => :inequal,
        :elements => {
          :old => {
            :value => {"one" => {"foo" => "bar", "baz" => "quux", "ying" => "yang"}},
            :type => :hash,
            :size => 1
          },
          :new => {
            :value => {"one" => {"foo" => "bar"}},
            :type => :hash,
            :size => 1
          },
          :common => {
            :value => nil,
            :type => :hash,
            :size => 1
          }
        },
        :details => [
          [:inequal, [
            {
              :state => :inequal,
              :elements => {
                :old => {
                  :value => {"foo" => "bar", "baz" => "quux", "ying" => "yang"},
                  :type => :hash,
                  :size => 3,
                  :key => "one"
                },
                :new => {
                  :value => {"foo" => "bar"},
                  :type => :hash,
                  :size => 1,
                  :key => "one"
                },
                :common => {
                  :value => nil,
                  :type => :hash,
                  :size => nil,
                  :key => "one"
                }
              },
              :details => [
                [:equal, [
                  {
                    :state => :equal,
                    :elements => {
                      :old => {:value => "bar", :type => :string, :key => "foo"},
                      :new => {:value => "bar", :type => :string, :key => "foo"},
                      :common => {:value => "bar", :type => :string, :key => "foo"}
                    }
                  }
                ]],
                [:missing, [
                  {
                    :state => :missing,
                    :elements => {
                      :old => {:value => "quux", :type => :string, :key => "baz"},
                      :new => nil,
                      :common => nil
                    }
                  }
                ]],
                [:missing, [
                  {
                    :state => :missing,
                    :elements => {
                      :old => {:value => "yang", :type => :string, :key => "ying"},
                      :new => nil,
                      :common => nil
                    }
                  }
                ]]
              ]
            }
          ]]
        ]
      }
      described_class.report(change, to: stdout)
      msg = <<EOT
Error: Hashes of same size but with differing elements.

Expected: {"one"=>{"foo"=>"bar", "baz"=>"quux", "ying"=>"yang"}}
Got: {"one"=>{"foo"=>"bar"}}

Details:
- *["one"]: Hashes of differing size (no differing elements).
  - *["baz" -> ?]: "quux" unexpectedly missing.
  - *["ying" -> ?]: "yang" unexpectedly missing.
EOT
      stdout.string.should == msg
    end

    specify "deeper hashes with variously differing hashes" do
      change = {
        :state => :inequal,
        :elements => {
          :old => {
            :value => {
              "foo" => {1 => {"baz" => {"quux" => 2}, "foz" => {"fram" => "frazzle"}}},
              "biz" => {:fiz => "gram", 1 => {2 => :sym}},
              "bananas" => {:apple => 11}
            },
            :type => :hash,
            :size => 3
          },
          :new => {
            :value => {
              "foo" => {1 => {"foz" => {"fram" => "razzle"}}},
              "biz" => {42 => {:raz => "matazz"}, :fiz => "graeme", 1 => 3}
            },
            :type => :hash,
            :size => 2
          },
          :common => {
            :value => nil,
            :type => :hash,
            :size => nil
          }
        },
        :details => [
          [:inequal, [
            {
              :state => :inequal,
              :elements => {
                :old => {
                  :value => {1 => {"baz" => {"quux" => 2}, "foz" => {"fram" => "frazzle"}}},
                  :type => :hash,
                  :size => 1,
                  :key => "foo"
                },
                :new => {
                  :value => {1 => {"foz" => {"fram" => "razzle"}}},
                  :type => :hash,
                  :size => 1,
                  :key => "foo"
                },
                :common => {
                  :value => nil,
                  :type => :hash,
                  :size => 1,
                  :key => "foo"
                }
              },
              :details => [
                [:inequal, [
                  {
                    :state => :inequal,
                    :elements => {
                      :old => {
                        :value => {"baz" => {"quux" => 2}, "foz" => {"fram" => "frazzle"}},
                        :type => :hash,
                        :size => 2,
                        :key => 1
                      },
                      :new => {
                        :value => {"foz" => {"fram" => "razzle"}},
                        :type => :hash,
                        :size => 1,
                        :key => 1
                      },
                      :common => {
                        :value => nil,
                        :type => :hash,
                        :size => nil,
                        :key => 1
                      }
                    },
                    :details => [
                      [:missing, [
                        {
                          :state => :missing,
                          :elements => {
                            :old => {:value => {"quux" => 2}, :type => :hash, :size => 1, :key => "baz"},
                            :new => nil,
                            :common => nil
                          }
                        }
                      ]],
                      [:inequal, [
                        {
                          :state => :inequal,
                          :elements => {
                            :old => {:value => {"fram" => "frazzle"}, :type => :hash, :size => 1, :key => "foz"},
                            :new => {:value => {"fram" => "razzle"}, :type => :hash, :size => 1, :key => "foz"},
                            :common => {:value => nil, :type => :hash, :size => 1, :key => "foz"}
                          },
                          :details => [
                            [:inequal, [
                              {
                                :state => :inequal,
                                :elements => {
                                  :old => {:value => "frazzle", :type => :string, :key => "fram"},
                                  :new => {:value => "razzle", :type => :string, :key => "fram"},
                                  :common => {:value => nil, :type => :string, :key => "fram"}
                                }
                              }
                            ]]
                          ]
                        }
                      ]]
                    ]
                  }
                ]]
              ]
            }
          ]],
          [:inequal, [
            {
              :state => :inequal,
              :elements => {
                :old => {:value => {:fiz => "gram", 1 => {2 => :sym}}, :type => :hash, :size => 2, :key => "biz"},
                :new => {:value => {42 => {:raz => "matazz"}, :fiz => "graeme", 1 => 3}, :type => :hash, :size => 3, :key => "biz"},
                :common => {:value => nil, :type => :hash, :size => nil, :key => "biz"}
              },
              :details => [
                [:inequal, [
                  {
                    :state => :inequal,
                    :elements => {
                      :old => {:value => "gram", :type => :string, :key => :fiz},
                      :new => {:value => "graeme", :type => :string, :key => :fiz},
                      :common => {:value => nil, :type => :string, :key => :fiz}
                    }
                  }
                ]],
                [:inequal, [
                  {
                    :state => :inequal,
                    :elements => {
                      :old => {:value => {2 => :sym}, :type => :hash, :size => 1, :key => 1},
                      :new => {:value => 3, :type => :number, :key => 1},
                      :common => {:value => nil, :type => nil, :key => 1}
                    }
                  }
                ]],
                [:surplus, [
                  {
                    :state => :surplus,
                    :elements => {
                      :old => nil,
                      :new => {:value => {:raz => "matazz"}, :type => :hash, :size => 1, :key => 42},
                      :common => nil
                    }
                  }
                ]]
              ]
            }
          ]],
          [:missing, [
            {
              :state => :missing,
              :elements => {
                :old => {:value => {:apple => 11}, :type => :hash, :size => 1, :key => "bananas"},
                :new => nil,
                :common => nil
              }
            }
          ]]
        ]
      }
      described_class.report(change, to: stdout)
      msg = <<EOT
Error: Hashes of differing size and elements.

Expected: {"foo"=>{1=>{"baz"=>{"quux"=>2}, "foz"=>{"fram"=>"frazzle"}}}, "biz"=>{:fiz=>"gram", 1=>{2=>:sym}}, "bananas"=>{:apple=>11}}
Got: {"foo"=>{1=>{"foz"=>{"fram"=>"razzle"}}}, "biz"=>{42=>{:raz=>"matazz"}, :fiz=>"graeme", 1=>3}}

Details:
- *["foo"]: Hashes of same size but with differing elements.
  - *[1]: Hashes of differing size and elements.
    - *["baz" -> ?]: {"quux"=>2} unexpectedly missing.
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
  - *[? -> 42]: {:raz=>"matazz"} unexpectedly found.
- *["bananas" -> ?]: {:apple=>11} unexpectedly missing.
EOT
      stdout.string.should == msg
    end

    specify "arrays and hashes, mixed" do
      change = {
        :state => :inequal,
        :elements => {
          :old => {
            :value => {
              "foo" => {1 => {"baz" => {"quux" => 2}, "foz" => ["apple", "bananna", "orange"]}},
              "biz" => {:fiz => ["bing", "bong", "bam"], 1 => {2 => :sym}},
              "bananas" => {:apple => 11}
            },
            :type => :hash,
            :size => 3
          },
          :new => {
            :value => {
              "foo" => {1 => {"foz" => ["apple", "banana", "orange"]}},
              "biz" => {42 => {:raz => "matazz"}, :fiz => ["bang", "bong", "bam", "splat"], 1 => 3}
            },
            :type => :hash,
            :size => 2
          },
          :common => {
            :value => nil,
            :type => :hash,
            :size => nil
          }
        },
        :details => [
          [:inequal, [
            {
              :state => :inequal,
              :elements => {
                :old => {
                  :value => {1 => {"baz" => {"quux" => 2}, "foz" => ["apple", "bananna", "orange"]}},
                  :type => :hash,
                  :size => 1,
                  :key => "foo"
                },
                :new => {
                  :value => {1 => {"foz" => ["apple", "banana", "orange"]}},
                  :type => :hash,
                  :size => 1,
                  :key => "foo"
                },
                :common => {
                  :value => nil,
                  :type => :hash,
                  :size => 1,
                  :key => "foo"
                }
              },
              :details => [
                [:inequal, [
                  {
                    :state => :inequal,
                    :elements => {
                      :old => {
                        :value => {"baz" => {"quux" => 2}, "foz" => ["apple", "bananna", "orange"]},
                        :type => :hash,
                        :size => 2,
                        :key => 1
                      },
                      :new => {
                        :value => {"foz" => ["apple", "banana", "orange"]},
                        :type => :hash,
                        :size => 1,
                        :key => 1
                      },
                      :common => {
                        :value => nil,
                        :type => :hash,
                        :size => nil,
                        :key => 1
                      }
                    },
                    :details => [
                      [:missing, [
                        {
                          :state => :missing,
                          :elements => {
                            :old => {:value => {"quux" => 2}, :type => :hash, :size => 1, :key => "baz"},
                            :new => nil,
                            :common => nil
                          }
                        }
                      ]],
                      [:inequal, [
                        {
                          :state => :inequal,
                          :elements => {
                            :old => {:value => ["apple", "bananna", "orange"], :type => :array, :size => 3, :key => "foz"},
                            :new => {:value => ["apple", "banana", "orange"], :type => :array, :size => 3, :key => "foz"},
                            :common => {:value => nil, :type => :array, :size => 3, :key => "foz"}
                          },
                          :details => [
                            [:equal, [
                              {
                                :state => :equal,
                                :elements => {
                                  :old => {:value => "apple", :type => :string, :key => 0},
                                  :new => {:value => "apple", :type => :string, :key => 0},
                                  :common => {:value => "apple", :type => :string, :key => 0}
                                }
                              }
                            ]],
                            [:inequal, [
                              {
                                :state => :inequal,
                                :elements => {
                                  :old => {:value => "bananna", :type => :string, :key => 1},
                                  :new => {:value => "banana", :type => :string, :key => 1},
                                  :common => {:value => nil, :type => :string, :key => 1}
                                }
                              }
                            ]],
                            [:equal, [
                              {
                                :state => :equal,
                                :elements => {
                                  :old => {:value => "orange", :type => :string, :key => 2},
                                  :new => {:value => "orange", :type => :string, :key => 2},
                                  :common => {:value => "orange", :type => :string, :key => 2}
                                }
                              }
                            ]]
                          ]
                        }
                      ]]
                    ]
                  }
                ]]
              ]
            }
          ]],
          [:inequal, [
            {
              :state => :inequal,
              :elements => {
                :old => {
                  :value => {:fiz => ["bing", "bong", "bam"], 1 => {2 => :sym}},
                  :type => :hash,
                  :size => 2,
                  :key => "biz"
                },
                :new => {
                  :value => {42 => {:raz => "matazz"}, :fiz => ["bang", "bong", "bam", "splat"], 1 => 3},
                  :type => :hash,
                  :size => 3,
                  :key => "biz"
                },
                :common => {
                  :value => nil,
                  :type => :hash,
                  :size => nil,
                  :key => "biz"
                }
              },
              :details => [
                [:inequal, [
                  {
                    :state => :inequal,
                    :elements => {
                      :old => {:value => ["bing", "bong", "bam"], :type => :array, :size => 3, :key => :fiz},
                      :new => {:value => ["bang", "bong", "bam", "splat"], :type => :array, :size => 4, :key => :fiz},
                      :common => {:value => nil, :type => :array, :size => nil, :key => :fiz}
                    },
                    :details => [
                      [:inequal, [
                        {
                          :state => :inequal,
                          :elements => {
                            :old => {:value => "bing", :type => :string, :key => 0},
                            :new => {:value => "bang", :type => :string, :key => 0},
                            :common => {:value => nil, :type => :string, :key => 0}
                          }
                        }
                      ]],
                      [:equal, [
                        {
                          :state => :equal,
                          :elements => {
                            :old => {:value => "bong", :type => :string, :key => 1},
                            :new => {:value => "bong", :type => :string, :key => 1},
                            :common => {:value => "bong", :type => :string, :key => 1}
                          }
                        }
                      ]],
                      [:equal, [
                        {
                          :state => :equal,
                          :elements => {
                            :old => {:value => "bam", :type => :string, :key => 2},
                            :new => {:value => "bam", :type => :string, :key => 2},
                            :common => {:value => "bam", :type => :string, :key => 2}
                          }
                        }
                      ]],
                      [:surplus, [
                        {
                          :state => :surplus,
                          :elements => {
                            :old => nil,
                            :new => {:value => "splat", :type => :string, :key => 3},
                            :common => nil
                          }
                        }
                      ]]
                    ]
                  }
                ]],
                [:inequal, [
                  {
                    :state => :inequal,
                    :elements => {
                      :old => {:value => {2 => :sym}, :type => :hash, :size => 1, :key => 1},
                      :new => {:value => 3, :type => :number, :key => 1},
                      :common => {:value => nil, :type => nil, :key => 1}
                    }
                  }
                ]],
                [:surplus, [
                  {
                    :state => :surplus,
                    :elements => {
                      :old => nil,
                      :new => {:value => {:raz => "matazz"}, :type => :hash, :size => 1, :key => 42},
                      :common => nil
                    }
                  }
                ]]
              ]
            }
          ]],
          [:missing, [
            {
              :state => :missing,
              :elements => {
                :old => {:value => {:apple => 11}, :type => :hash, :size => 1, :key => "bananas"},
                :new => nil,
                :common => nil
              }
            }
          ]]
        ]
      }
      described_class.report(change, to: stdout)
      msg = <<EOT
Error: Hashes of differing size and elements.

Expected: {"foo"=>{1=>{"baz"=>{"quux"=>2}, "foz"=>["apple", "bananna", "orange"]}}, "biz"=>{:fiz=>["bing", "bong", "bam"], 1=>{2=>:sym}}, "bananas"=>{:apple=>11}}
Got: {"foo"=>{1=>{"foz"=>["apple", "banana", "orange"]}}, "biz"=>{42=>{:raz=>"matazz"}, :fiz=>["bang", "bong", "bam", "splat"], 1=>3}}

Details:
- *["foo"]: Hashes of same size but with differing elements.
  - *[1]: Hashes of differing size and elements.
    - *["baz" -> ?]: {"quux"=>2} unexpectedly missing.
    - *["foz"]: Arrays of same size but with differing elements.
      - *[1]: Differing strings.
        - Expected: "bananna"
        - Got: "banana"
- *["biz"]: Hashes of differing size and elements.
  - *[:fiz]: Arrays of differing size and elements.
    - *[0]: Differing strings.
      - Expected: "bing"
      - Got: "bang"
    - *[? -> 3]: "splat" unexpectedly found after "bam".
  - *[1]: Values of differing type.
    - Expected: {2=>:sym}
    - Got: 3
  - *[? -> 42]: {:raz=>"matazz"} unexpectedly found.
- *["bananas" -> ?]: {:apple=>11} unexpectedly missing.
EOT
      stdout.string.should == msg
    end

    specify "collapsed output" do
      change = {
        :state => :inequal,
        :elements => {
          :old => {
            :value => {
              "foo" => {1 => {"baz" => {"quux" => 2}, "foz" => ["apple", "bananna", "orange"]}},
              "biz" => {:fiz => ["bing", "bong", "bam"], 1 => {2 => :sym}},
              "bananas" => {:apple => 11}
            },
            :type => :hash,
            :size => 3
          },
          :new => {
            :value => {
              "foo" => {1 => {"foz" => ["apple", "banana", "orange"]}},
              "biz" => {42 => {:raz => "matazz"}, :fiz => ["bang", "bong", "bam", "splat"], 1 => 3}
            },
            :type => :hash,
            :size => 2
          },
          :common => {
            :value => nil,
            :type => :hash,
            :size => nil
          }
        },
        :details => [
          [:inequal, [
            {
              :state => :inequal,
              :elements => {
                :old => {
                  :value => {1 => {"baz" => {"quux" => 2}, "foz" => ["apple", "bananna", "orange"]}},
                  :type => :hash,
                  :size => 1,
                  :key => "foo"
                },
                :new => {
                  :value => {1 => {"foz" => ["apple", "banana", "orange"]}},
                  :type => :hash,
                  :size => 1,
                  :key => "foo"
                },
                :common => {
                  :value => nil,
                  :type => :hash,
                  :size => 1,
                  :key => "foo"
                }
              },
              :details => [
                [:inequal, [
                  {
                    :state => :inequal,
                    :elements => {
                      :old => {
                        :value => {"baz" => {"quux" => 2}, "foz" => ["apple", "bananna", "orange"]},
                        :type => :hash,
                        :size => 2,
                        :key => 1
                      },
                      :new => {
                        :value => {"foz" => ["apple", "banana", "orange"]},
                        :type => :hash,
                        :size => 1,
                        :key => 1
                      },
                      :common => {
                        :value => nil,
                        :type => :hash,
                        :size => nil,
                        :key => 1
                      }
                    },
                    :details => [
                      [:missing, [
                        {
                          :state => :missing,
                          :elements => {
                            :old => {:value => {"quux" => 2}, :type => :hash, :size => 1, :key => "baz"},
                            :new => nil,
                            :common => nil,
                          }
                        }
                      ]],
                      [:inequal, [
                        {
                          :state => :inequal,
                          :elements => {
                            :old => {:value => ["apple", "bananna", "orange"], :type => :array, :size => 3, :key => "foz"},
                            :new => {:value => ["apple", "banana", "orange"], :type => :array, :size => 3, :key => "foz"},
                            :common => {:value => nil, :type => :array, :size => 3, :key => "foz"}
                          },
                          :details => [
                            [:equal, [
                              {
                                :state => :equal,
                                :elements => {
                                  :old => {:value => "apple", :type => :string, :key => 0},
                                  :new => {:value => "apple", :type => :string, :key => 0},
                                  :common => {:value => "apple", :type => :string, :key => 0}
                                }
                              }
                            ]],
                            [:inequal, [
                              {
                                :state => :inequal,
                                :elements => {
                                  :old => {:value => "bananna", :type => :string, :key => 1},
                                  :new => {:value => "banana", :type => :string, :key => 1},
                                  :common => {:value => nil, :type => :string, :key => 1}
                                }
                              }
                            ]],
                            [:equal, [
                              {
                                :state => :equal,
                                :elements => {
                                  :old => {:value => "orange", :type => :string, :key => 2},
                                  :new => {:value => "orange", :type => :string, :key => 2},
                                  :common => {:value => "orange", :type => :string, :key => 2}
                                }
                              }
                            ]]
                          ]
                        }
                      ]]
                    ]
                  }
                ]]
              ]
            }
          ]],
          [:inequal, [
            {
              :state => :inequal,
              :elements => {
                :old => {
                  :value => {:fiz => ["bing", "bong", "bam"], 1 => {2 => :sym}},
                  :type => :hash,
                  :size => 2,
                  :key => "biz"
                },
                :new => {
                  :value => {42 => {:raz => "matazz"}, :fiz => ["bang", "bong", "bam", "splat"], 1 => 3},
                  :type => :hash,
                  :size => 3,
                  :key => "biz"
                },
                :common => {
                  :value => nil,
                  :type => :hash,
                  :size => nil,
                  :key => "biz"
                }
              },
              :details => [
                [:inequal, [
                  {
                    :state => :inequal,
                    :elements => {
                      :old => {:value => ["bing", "bong", "bam"], :type => :array, :size => 3, :key => :fiz},
                      :new => {:value => ["bang", "bong", "bam", "splat"], :type => :array, :size => 4, :key => :fiz},
                      :common => {:value => nil, :type => :array, :size => nil, :key => :fiz}
                    },
                    :details => [
                      [:inequal, [
                        {
                          :state => :inequal,
                          :elements => {
                            :old => {:value => "bing", :type => :string, :key => 0},
                            :new => {:value => "bang", :type => :string, :key => 0},
                            :common => {:value => nil, :type => :string, :key => 0}
                          }
                        }
                      ]],
                      [:equal, [
                        {
                          :state => :equal,
                          :elements => {
                            :old => {:value => "bong", :type => :string, :key => 1},
                            :new => {:value => "bong", :type => :string, :key => 1},
                            :common => {:value => "bong", :type => :string, :key => 1}
                          }
                        }
                      ]],
                      [:equal, [
                        {
                          :state => :equal,
                          :elements => {
                            :old => {:value => "bam", :type => :string, :key => 2},
                            :new => {:value => "bam", :type => :string, :key => 2},
                            :common => {:value => "bam", :type => :string, :key => 2}
                          }
                        }
                      ]],
                      [:surplus, [
                        {
                          :state => :surplus,
                          :elements => {
                            :old => nil,
                            :new => {:value => "splat", :type => :string, :key => 3},
                            :common => nil
                          }
                        }
                      ]]
                    ]
                  }
                ]],
                [:inequal, [
                  {
                    :state => :inequal,
                    :elements => {
                      :old => {:value => {2 => :sym}, :type => :hash, :size => 1, :key => 1},
                      :new => {:value => 3, :type => :number, :key => 1},
                      :common => {:value => nil, :type => nil, :key => 1}
                    }
                  }
                ]],
                [:surplus, [
                  {
                    :state => :surplus,
                    :elements => {
                      :old => nil,
                      :new => {:value => {:raz => "matazz"}, :type => :hash, :size => 1, :key => 42},
                      :common => nil
                    }
                  }
                ]]
              ]
            }
          ]],
          [:missing, [
            {
              :state => :missing,
              :elements => {
                :old => {:value => {:apple => 11}, :type => :hash, :size => 1, :key => "bananas"},
                :new => nil,
                :common => nil
              }
            }
          ]]
        ]
      }
      described_class.report(change, to: stdout, collapsed: true)
      msg = <<EOT
Error: Hashes of differing size and elements.

Expected: {"foo"=>{1=>{"baz"=>{"quux"=>2}, "foz"=>["apple", "bananna", "orange"]}}, "biz"=>{:fiz=>["bing", "bong", "bam"], 1=>{2=>:sym}}, "bananas"=>{:apple=>11}}
Got: {"foo"=>{1=>{"foz"=>["apple", "banana", "orange"]}}, "biz"=>{42=>{:raz=>"matazz"}, :fiz=>["bang", "bong", "bam", "splat"], 1=>3}}

Details:
- *["foo"][1]["baz" -> ?]: {"quux"=>2} unexpectedly missing.
- *["foo"][1]["foz"][1]: Differing strings.
  - Expected: "bananna"
  - Got: "banana"
- *["biz"][:fiz][0]: Differing strings.
  - Expected: "bing"
  - Got: "bang"
- *["biz"][:fiz][? -> 3]: "splat" unexpectedly found after "bam".
- *["biz"][1]: Values of differing type.
  - Expected: {2=>:sym}
  - Got: 3
- *["biz"][? -> 42]: {:raz=>"matazz"} unexpectedly found.
- *["bananas" -> ?]: {:apple=>11} unexpectedly missing.
EOT
      stdout.string.should == msg
    end

    specify "custom string differ"

    specify "custom array differ"

    specify "custom hash differ"

    specify "custom object differ"
  end
end
