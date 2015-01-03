require 'spec_helper'

describe SuperDiff::Differ do
  before do
    @differ = SuperDiff::Differ.new
  end

  describe '#diff', 'generates correct data for' do
    specify "same strings" do
      actual = @differ.diff("foo", "foo")
      expected = {
        :state => :equal,
        :elements => {
          :old => {:value => "foo", :type => :string},
          :new => {:value => "foo", :type => :string},
          :common => {:value => "foo", :type => :string}
        }
      }
      actual.should == expected
    end

    specify "differing strings" do
      actual = @differ.diff("foo", "bar")
      expected = {
        :state => :inequal,
        :elements => {
          :old => {:value => "foo", :type => :string},
          :new => {:value => "bar", :type => :string},
          :common => {:value => nil, :type => :string}
        }
      }
      actual.should == expected
    end

    specify "same numbers" do
      actual = @differ.diff(1, 1)
      expected = {
        :state => :equal,
        :elements => {
          :old => {:value => 1, :type => :number},
          :new => {:value => 1, :type => :number},
          :common => {:value => 1, :type => :number}
        }
      }
      actual.should == expected
    end

    specify "differing numbers" do
      actual = @differ.diff(1, 2)
      expected = {
        :state => :inequal,
        :elements => {
          :old => {:value => 1, :type => :number},
          :new => {:value => 2, :type => :number},
          :common => {:value => nil, :type => :number}
        }
      }
      actual.should == expected
    end

    specify "values of differing simple types" do
      actual = @differ.diff("foo", 1)
      expected = {
        :state => :inequal,
        :elements => {
          :old => {:value => "foo", :type => :string},
          :new => {:value => 1, :type => :number},
          :common => {:value => nil, :type => nil}
        }
      }
      actual.should == expected
    end

    specify "values of differing complex types" do
      actual = @differ.diff("foo", %w(zing zang))
      expected = {
        :state => :inequal,
        :elements => {
          :old => {:value => "foo", :type => :string},
          :new => {:value => %w(zing zang), :size => 2, :type => :array},
          :common => {:value => nil, :type => nil}
        }
      }
      actual.should == expected
    end

    specify "shallow arrays of same size but with differing elements" do
      actual = @differ.diff(["foo", "bar"], ["foo", "baz"])
      expected = {
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
            [
              [
                # this node
                {
                  :state => :missing,
                  :elements => {
                    :old => {:value => "bar", :type => :string, :key => 1},
                    :new => nil,
                    :common => nil
                  }
                },
                {
                  :state => :surplus,
                  :elements => {
                    :old => nil,
                    :new => {:value => "baz", :type => :string, :key => 1},
                    :common => nil
                  }
                }
              ],
              # children
              []
            ]
          ]]
        ]
      }
      actual.should == expected
    end

    # Continue to just go through these tests and make them pass...........

    specify "shallow arrays with inserted elements" do
      actual = @differ.diff(
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
      actual = @differ.diff(
        [["foo", "bar"], ["baz", "quux"]],
        [["foo", "biz"], ["baz", "quarks"]]
      )
      expected = {
        :state => :inequal,
        :elements => {
          :old => {:value => [["foo", "bar"], ["baz", "quux"]], :type => :array, :size => 2},
          :new => {:value => [["foo", "biz"], ["baz", "quarks"]], :type => :array, :size => 2},
          :common => {:value => nil, :type => :array, :size => 2}
        },
        :details => [
          [:inequal, [
            [
              [
                {
                  :state => :missing,
                  :elements => {
                    :old => {:value => ["foo", "bar"], :type => :array, :size => 2, :key => 0},
                    :new => nil,
                    :common => nil
                  }
                },
                {
                  :state => :surplus,
                  :elements => {
                    :old => nil,
                    :new => {:value => ["foo", "biz"], :type => :array, :size => 2, :key => 0},
                    :common => nil
                  }
                }
              ],
              [
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
                  [
                    [
                      {
                        :state => :missing,
                        :elements => {
                          :old => {:value => "bar", :type => :string, :key => 1},
                          :new => nil,
                          :common => nil
                        }
                      },
                      {
                        :state => :surplus,
                        :elements => {
                          :old => nil,
                          :new => {:value => "biz", :type => :string, :key => 1},
                          :common => nil
                        }
                      }
                    ],
                    [],
                  ]
                ]]
              ]
            ],
            [
              [
                {
                  :state => :missing,
                  :elements => {
                    :old => {:value => ["baz", "quux"], :type => :array, :size => 2, :key => 1},
                    :new => nil,
                    :common => nil
                  }
                },
                {
                  :state => :surplus,
                  :elements => {
                    :old => nil,
                    :new => {:value => ["baz", "quarks"], :type => :array, :size => 2, :key => 1},
                    :common => nil
                  }
                }
              ],
              [
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
                  [
                    [
                      {
                        :state => :missing,
                        :elements => {
                          :old => {:value => "quux", :type => :string, :key => 1},
                          :new => nil,
                          :common => nil
                        }
                      },
                      {
                        :state => :surplus,
                        :elements => {
                          :old => nil,
                          :new => {:value => "quarks", :type => :string, :key => 1},
                          :common => nil
                        }
                      }
                    ],
                    []
                  ]
                ]]
              ]
            ]
          ]]
        ]
      }
      actual.should == expected
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
            [
              [
                {
                  :state => :missing,
                  :elements => {
                    :old => {:value => "foo", :type => :string, :key => 0},
                    :new => nil,
                    :common => nil
                  }
                },
                {
                  :state => :surplus,
                  :elements => {
                    :old => nil,
                    :new => {:value => "foz", :type => :string, :key => 0},
                    :common => nil
                  }
                },
              ],
              []
            ],
            [
              [
                {
                  :state => :missing,
                  :elements => {
                    :old => {:value => ["bar", ["baz", "quux"]], :type => :array, :size => 2, :key => 1},
                    :new => nil,
                    :common => nil
                  }
                },
                {
                  :state => :surplus,
                  :elements => {
                    :old => nil,
                    :new => {:value => "bar", :type => :string, :key => 1},
                    :common => nil
                  }
                }
              ],
              []
            ]
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
            [
              [
                {
                  :state => :missing,
                  :elements => {
                    :old => {
                      :value => ["blargh", "zing", "fooz", ["raz", ["vermouth"]]],
                      :type => :array,
                      :size => 4,
                      :key => 3
                    },
                    :new => nil,
                    :common => nil
                  }
                },
                {
                  :state => :surplus,
                  :elements => {
                    :old => nil,
                    :new => {
                      :value => ["blargh", "gragh", 1, ["raz", ["ralston"]]],
                      :type => :array,
                      :size => 4,
                      :key => 3
                    },
                    :common => nil,
                  }
                }
              ],
              [
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
                  [
                    [
                      {
                        :state => :missing,
                        :elements => {
                          :old => {:value => "zing", :type => :string, :key => 1},
                          :new => nil,
                          :common => nil
                        }
                      },
                      {
                        :state => :surplus,
                        :elements => {
                          :old => nil,
                          :new => {:value => "gragh", :type => :string, :key => 1},
                          :common => nil
                        }
                      }
                    ],
                    []
                  ],
                  [
                    [
                      {
                        :state => :missing,
                        :elements => {
                          :old => {:value => "fooz", :type => :string, :key => 2},
                          :new => nil,
                          :common => nil
                        }
                      },
                      {
                        :state => :surplus,
                        :elements => {
                          :old => nil,
                          :new => {:value => 1, :type => :number, :key => 2},
                          :common => nil
                        }
                      }
                    ],
                    []
                  ],
                  [
                    [
                      {
                        :state => :missing,
                        :elements => {
                          :old => {:value => ["raz", ["vermouth"]], :type => :array, :size => 2, :key => 3},
                          :new => nil,
                          :common => nil
                        }
                      },
                      {
                        :state => :surplus,
                        :elements => {
                          :old => nil,
                          :new => {:value => ["raz", ["ralston"]], :type => :array, :size => 2, :key => 3},
                          :common => nil
                        }
                      }
                    ],
                    [
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
                        [
                          [
                            {
                              :state => :missing,
                              :elements => {
                                :old => {:value => ["vermouth"], :type => :array, :size => 1, :key => 1},
                                :new => nil,
                                :common => nil
                              }
                            },
                            {
                              :state => :surplus,
                              :elements => {
                                :old => nil,
                                :new => {:value => ["ralston"], :type => :array, :size => 1, :key => 1},
                                :common => nil
                              }
                            }
                          ],
                          [
                            [:inequal, [
                              [
                                [
                                  {
                                    :state => :missing,
                                    :elements => {
                                      :old => {:value => "vermouth", :type => :string, :key => 0},
                                      :new => nil,
                                      :common => nil
                                    }
                                  },
                                  {
                                    :state => :surplus,
                                    :elements => {
                                      :old => nil,
                                      :new => {:value => "ralston", :type => :string, :key => 0},
                                      :common => nil
                                    }
                                  }
                                ],
                                []
                              ]
                            ]]
                          ]
                        ]
                      ]]
                    ]
                  ]
                ]]
              ]
            ]
          ]]
        ]
      }
      actual.should == expected
    end

    specify "shallow arrays with surplus elements that appear at the beginning" do
      actual = @differ.diff(["foo", "bar"], ["baz", "quux", "foo", "bar"])
      expected = {
        :state => :inequal,
        :elements => {
          :old => {:value => ["foo", "bar"], :type => :array, :size => 2},
          :new => {:value => ["baz", "quux", "foo", "bar"], :type => :array, :size => 4},
          :common => {:value => nil, :type => :array, :size => nil}
        },
        :details => [
          [:inequal, [
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
            },
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
      actual.must == expected
    end

    specify "shallow arrays with surplus elements that appear at the end" do
      actual = @differ.diff(["foo", "bar"], ["foo", "bar", "baz", "quux"])
      expected = {
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
            },
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
              :state => :surplus,
              :elements => {
                :old => nil,
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
      actual.must == expected
    end

    specify "shallow arrays with surplus elements that appear after a changed element" do
      actual = @differ.diff(["foo", "bar", "baz"], ["foo", "bar", "buzz", "quux", "blargh"])
      expected = {
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
            },
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
            [
              [
                {
                  :state => :missing,
                  :elements => {
                    :old => {:value => "baz", :type => :string, :key => 2},
                    :new => nil,
                    :common => nil
                  }
                },
                {
                  :state => :surplus,
                  :elements => {
                    :old => nil,
                    :new => {:value => "buzz", :type => :string, :key => 2},
                    :common => nil
                  }
                }
              ],
              []
            ],
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
      actual.must == expected
    end

    specify "shallow arrays with missing elements that were removed at the beginning" do
      actual = @differ.diff(["baz", "quux", "foo", "bar"], ["foo", "bar"])
      expected = {
        :state => :inequal,
        :elements => {
          :old => {:value => ["baz", "quux", "foo", "bar"], :type => :array, :size => 4},
          :new => {:value => ["foo", "bar"], :type => :array, :size => 2},
          :common => {:value => nil, :type => :array, :size => nil}
        },
        :details => [
          [:inequal, [
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
            },
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
      actual.should == expected
    end

    specify "shallow arrays with missing elements that were removed at the end" do
      actual = @differ.diff(["foo", "bar", "baz", "quux"], ["foo", "bar"])
      expected = {
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
            },
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
      actual.must == expected
    end

    specify "shallow arrays with missing elements that were removed after a changed element" do
      actual = @differ.diff(["foo", "bar", "baz", "quux", "blargh"], ["foo", "bar", "buzz"])
      expected = {
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
            },
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
            [
              [
                {
                  :state => :missing,
                  :elements => {
                    :old => {:value => "baz", :type => :string, :key => 2},
                    :new => nil,
                    :common => nil
                  }
                },
                {
                  :state => :surplus,
                  :elements => {
                    :old => nil,
                    :new => {:value => "buzz", :type => :string, :key => 2},
                    :common => nil
                  }
                }
              ],
              []
            ],
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
      actual.should == expected
    end

    specify "deep arrays with surplus elements" do
      actual = @differ.diff(
        ["foo", ["bar", "baz"], "ying"],
        ["foo", ["bar", "quux", "zing", "baz", "blargh"], "yang", "ying"]
      )
      expected = {
        :state => :inequal,
        :elements => {
          :old => {:value => ["foo", ["bar", "baz"], "ying"], :type => :array, :size => 3},
          :new => {:value => ["foo", ["bar", "quux", "zing", "baz", "blargh"], "yang", "ying"], :type => :array, :size => 4},
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
              }
            }
          ]],
          [:inequal, [
            [
              # this node
              [
                {
                  :state => :missing,
                  :elements => {
                    :old => {:value => ["bar", "baz"], :type => :array, :key => 1, :size => 2},
                    :new => nil,
                    :common => nil
                  }
                },
                {
                  :state => :surplus,
                  :elements => {
                    :old => nil,
                    :new => {:value => ["bar", "quux", "zing", "baz", "blargh"], :type => :array, :key => 1, :size => 5},
                    :common => nil
                  }
                }
              ],
              # children
              [
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
                [:inequal, [
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
                [:inequal, [
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
            ],
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
      actual.should == expected
    end

    specify "deep arrays with missing elements" do
      actual = @differ.diff(
        ["foo", ["bar", "baz", "quux", "blargh"], "ying"],
        ["foo", ["bar", "baz"], "ying"]
      )
      expected = {
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
            [
              [
                {
                  :state => :missing,
                  :elements => {
                    :old => {:value => ["bar", "baz", "quux", "blargh"], :type => :array, :size => 4, :key => 1},
                    :new => nil,
                    :common => nil
                  }
                },
                {
                  :state => :surplus,
                  :elements => {
                    :old => nil,
                    :new => {:value => ["bar", "baz"], :type => :array, :size => 2, :key => 1},
                    :common => nil
                  }
                }
              ],
              [
                [:equal, [
                  {
                    :state => :equal,
                    :elements => {
                      :old => {:value => "bar", :type => :string, :key => 0},
                      :new => {:value => "bar", :type => :string, :key => 0},
                      :common => {:value => "bar", :type => :string, :key => 0}
                    }
                  },
                  {
                    :state => :equal,
                    :elements => {
                      :old => {:value => "baz", :type => :string, :key => 1},
                      :new => {:value => "baz", :type => :string, :key => 1},
                      :common => {:value => "baz", :type => :string, :key => 1}
                    }
                  }
                ]],
                [:inequal, [
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
            ]
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
      actual.should == expected
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
          ["xyzzy", "blargh", "zing", 1, ["raz", ["ralston"]], ["foreal", ["zap"]]]
        ]
      )
      expected = {
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
            [
              [
                {
                  :state => :missing,
                  :elements => {
                    :old => {:value => "foo", :type => :string, :key => 0},
                    :new => nil,
                    :common => nil
                  }
                },
                {
                  :state => :surplus,
                  :elements => {
                    :old => nil,
                    :new => {:value => "foz", :type => :string, :key => 0},
                    :common => nil
                  }
                }
              ],
              []
            ]
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
            [
              [
                {
                  :state => :missing,
                  :elements => {
                    :old => {
                      :value => ["blargh", "zing", "fooz", ["raz", ["vermouth", "eee", "ffff"]]],
                      :type => :array,
                      :size => 4,
                      :key => 4
                    },
                    :new => nil,
                    :common => nil
                  }
                },
                {
                  :state => :surplus,
                  :elements => {
                    :old => nil,
                    :new => {
                      :value => ["xyzzy", "blargh", "zing", 1, ["raz", ["ralston"]], ["foreal", ["zap"]]],
                      :type => :array,
                      :size => 5,
                      :key => 3
                    },
                    :common => nil
                  }
                }
              ],
              [
                [:inequal, [
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
                  },
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
                  [
                    [
                      {
                        :state => :missing,
                        :elements => {
                          :old => {:value => "fooz", :type => :string, :key => 2},
                          :new => nil,
                          :common => nil
                        }
                      },
                      {
                        :state => :surplus,
                        :elements => {
                          :old => nil,
                          :new => {:value => 1, :type => :number, :key => 3},
                          :common => nil
                        }
                      }
                    ],
                    []
                  ],
                  [
                    [
                      {
                        :state => :missing,
                        :elements => {
                          :old => {:value => ["raz", ["vermouth", "eee", "ffff"]], :type => :array, :size => 2, :key => 3},
                          :new => nil,
                          :common => nil
                        }
                      },
                      {
                        :state => :surplus,
                        :elements => {
                          :old => nil,
                          :new => {:value => ["raz", ["ralston"]], :type => :array, :size => 2, :key => 4},
                          :common => nil
                        }
                      }
                    ],
                    [
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
                        [
                          [
                            {
                              :state => :missing,
                              :elements => {
                                :old => {:value => ["vermouth", "eee", "ffff"], :type => :array, :size => 3, :key => 1},
                                :new => nil,
                                :common => nil
                              }
                            },
                            {
                              :state => :surplus,
                              :elements => {
                                :old => nil,
                                :new => {:value => ["ralston"], :type => :array, :size => 1, :key => 1},
                                :common => nil
                              }
                            }
                          ],
                          [
                            [:inequal, [
                              [
                                [
                                  {
                                    :state => :missing,
                                    :elements => {
                                      :old => {:value => "vermouth", :type => :string, :key => 0},
                                      :new => nil,
                                      :common => nil
                                    }
                                  },
                                  {
                                    :state => :surplus,
                                    :elements => {
                                      :old => nil,
                                      :new => {:value => "ralston", :type => :string, :key => 0},
                                      :common => nil
                                    }
                                  }
                                ],
                                []
                              ],
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
                            ]]
                          ]
                        ]
                      ]]
                    ]
                  ]
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
            ]
          ]]
        ]
      }
      actual.should == expected
    end

    specify "shallow hashes of same size but differing elements" do
      actual = @differ.diff(
        {"foo" => "bar", "baz" => "quux"},
        {"foo" => "bar", "baz" => "quarx"}
      )
      expected = {
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
            [
              [
                {
                  :state => :missing,
                  :elements => {
                    :old => {:value => "quux", :type => :string, :key => "baz"},
                    :new => nil,
                    :common => nil
                  }
                },
                {
                  :state => :surplus,
                  :elements => {
                    :old => nil,
                    :new => {:value => "quarx", :type => :string, :key => "baz"},
                    :common => nil
                  }
                }
              ],
              []
            ]
          ]]
        ]
      }
      actual.should == expected
    end

    specify "deep hashes of same size but differing elements" do
      actual = @differ.diff(
        {"one" => {"foo" => "bar", "baz" => "quux"}, :two => {"ying" => 1, "zing" => :zang}},
        {"one" => {"foo" => "boo", "baz" => "quux"}, :two => {"ying" => "yang", "zing" => :bananas}}
      )
      expected = {
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
      actual.should == expected
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
      actual.should == expected
    end

    specify "shallow hashes with surplus elements" do
      actual = @differ.diff(
        {"foo" => "bar"},
        {"foo" => "bar", "baz" => "quux", "ying" => "yang"}
      )
      expected = {
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
      actual.should == expected
    end

    specify "shallow hashes with missing elements" do
      actual = @differ.diff(
        {"foo" => "bar", "baz" => "quux", "ying" => "yang"},
        {"foo" => "bar"}
      )
      expected = {
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
      actual.should == expected
    end

    specify "deep hashes with surplus elements" do
      actual = @differ.diff(
        {"one" => {"foo" => "bar"}},
        {"one" => {"foo" => "bar", "baz" => "quux", "ying" => "yang"}}
      )
      expected = {
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
      actual.should == expected
    end

    specify "deep hashes with missing elements" do
      actual = @differ.diff(
        {"one" => {"foo" => "bar", "baz" => "quux", "ying" => "yang"}},
        {"one" => {"foo" => "bar"}}
      )
      expected = {
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
      actual.should == expected
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
      actual.should == expected
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
      actual.should == expected
    end
  end
end
