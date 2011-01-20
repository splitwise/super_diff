require File.expand_path('../test_helper', __FILE__)

require 'stringio'

module SuperDiff
  class ReporterTest < TestCase
    def out
      @stdout.string
    end
  
    def setup
      @stdout = StringIO.new
      @differ = SuperDiff::Reporter.new(@stdout)
    end
  
    def test_differing_strings
      @differ.diff("foo", "bar")
      msg = <<EOT
Error: Differing strings.

Expected: "foo"
Got: "bar"
EOT
      assert_equal msg, out
    end
  
    def test_differing_numbers
      @differ.diff(1, 2)
      msg = <<EOT
Error: Differing numbers.

Expected: 1
Got: 2
EOT
      assert_equal msg, out
    end
  
    def test_differing_simple_types
      @differ.diff("foo", 1)
      msg = <<EOT
Error: Values of differing type.

Expected: "foo"
Got: 1
EOT
      assert_equal msg, out
    end
  
    def test_differing_complex_types
      @differ.diff("foo", %w(zing zang))
      msg = <<EOT
Error: Values of differing type.

Expected: "foo"
Got: ["zing", "zang"]
EOT
      assert_equal msg, out
    end
  
    def test_shallow_arrays_of_same_size_but_differing_elements
      @differ.diff(["foo", "bar"], ["foo", "baz"])
      msg = <<EOT
Error: Arrays of same size but with differing elements.

Expected: ["foo", "bar"]
Got: ["foo", "baz"]

Breakdown:
- *[1]: Differing strings.
  - Expected: "bar"
  - Got: "baz"
EOT
      assert_equal msg, out
    end
  
    def test_deep_arrays_of_same_size_but_differing_elements
      @differ.diff(
        [["foo", "bar"], ["baz", "quux"]],
        [["foo", "biz"], ["baz", "quarks"]]
      )
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
      assert_equal msg, out
    end
  
    def test_deeper_arrays_with_differing_elements
      @differ.diff(
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
      assert_equal msg, out
    end
  
    def test_shallow_arrays_with_surplus_elements
      @differ.diff(["foo", "bar"], ["foo", "bar", "baz", "quux"])
      msg = <<EOT
Error: Arrays of differing size (no differing elements).

Expected: ["foo", "bar"]
Got: ["foo", "bar", "baz", "quux"]

Breakdown:
- *[2]: Expected to not be present, but found "baz".
- *[3]: Expected to not be present, but found "quux".
EOT
      assert_equal msg, out
    end
  
    def test_shallow_arrays_with_missing_elements
      @differ.diff(["foo", "bar", "baz", "quux"], ["foo", "bar"])
      msg = <<EOT
Error: Arrays of differing size (no differing elements).

Expected: ["foo", "bar", "baz", "quux"]
Got: ["foo", "bar"]

Breakdown:
- *[2]: Expected to have been found, but missing "baz".
- *[3]: Expected to have been found, but missing "quux".
EOT
      assert_equal msg, out
    end
  
    def test_deep_arrays_with_surplus_elements
      @differ.diff(
        ["foo", ["bar", "baz"], "ying"],
        ["foo", ["bar", "baz", "quux", "blargh"], "ying"]
      )
      msg = <<EOT
Error: Arrays of same size but with differing elements.

Expected: ["foo", ["bar", "baz"], "ying"]
Got: ["foo", ["bar", "baz", "quux", "blargh"], "ying"]

Breakdown:
- *[1]: Arrays of differing size (no differing elements).
  - *[2]: Expected to not be present, but found "quux".
  - *[3]: Expected to not be present, but found "blargh".
EOT
      assert_equal msg, out
    end
  
    def test_deep_arrays_with_missing_elements
      @differ.diff(
        ["foo", ["bar", "baz", "quux", "blargh"], "ying"],
        ["foo", ["bar", "baz"], "ying"]
      )
      msg = <<EOT
Error: Arrays of same size but with differing elements.

Expected: ["foo", ["bar", "baz", "quux", "blargh"], "ying"]
Got: ["foo", ["bar", "baz"], "ying"]

Breakdown:
- *[1]: Arrays of differing size (no differing elements).
  - *[2]: Expected to have been found, but missing "quux".
  - *[3]: Expected to have been found, but missing "blargh".
EOT
      assert_equal msg, out
    end
  
    def test_deeper_arrays_with_variously_differing_arrays
      @differ.diff(
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
      assert_equal msg, out
    end
  
    def test_shallow_hashes_of_same_size_but_differing_elements
      @differ.diff(
        {"foo" => "bar", "baz" => "quux"},
        {"foo" => "bar", "baz" => "quarx"}
      )
      msg = <<EOT
Error: Hashes of same size but with differing elements.

Expected: {"foo"=>"bar", "baz"=>"quux"}
Got: {"foo"=>"bar", "baz"=>"quarx"}

Breakdown:
- *["baz"]: Differing strings.
  - Expected: "quux"
  - Got: "quarx"
EOT
      assert_equal msg, out
    end
  
    def test_deep_hashes_of_same_size_but_differing_elements
      @differ.diff(
        {"one" => {"foo" => "bar", "baz" => "quux"}, :two => {"ying" => 1, "zing" => :zang}},
        {"one" => {"foo" => "boo", "baz" => "quux"}, :two => {"ying" => "yang", "zing" => :bananas}}
      )
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
      assert_equal msg, out
    end
  
    def test_deeper_hashes_with_differing_elements
      @differ.diff(
        {
          "foo" => {1 => {"baz" => {"quux" => 2}, "foz" => {"fram" => "frazzle"}}},
          "biz" => {:fiz => "gram", 1 => {2 => :sym}}
        },
        {
          "foo" => {1 => {"baz" => "quarx", "foz" => {"fram" => "razzle"}}},
          "biz" => {:fiz => "graeme", 1 => 3}
        }
      )
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
      assert_equal msg, out
    end
  
    def test_shallow_hashes_with_surplus_elements
      @differ.diff(
        {"foo" => "bar"},
        {"foo" => "bar", "baz" => "quux", "ying" => "yang"}
      )
      msg = <<EOT
Error: Hashes of differing size (no differing elements).

Expected: {"foo"=>"bar"}
Got: {"foo"=>"bar", "baz"=>"quux", "ying"=>"yang"}

Breakdown:
- *["baz"]: Expected to not be present, but found "quux".
- *["ying"]: Expected to not be present, but found "yang".
EOT
      assert_equal msg, out
    end
  
    def test_shallow_hashes_with_missing_elements
      @differ.diff(
        {"foo" => "bar", "baz" => "quux", "ying" => "yang"},
        {"foo" => "bar"}
      )
      msg = <<EOT
Error: Hashes of differing size (no differing elements).

Expected: {"foo"=>"bar", "baz"=>"quux", "ying"=>"yang"}
Got: {"foo"=>"bar"}

Breakdown:
- *["baz"]: Expected to have been found, but missing "quux".
- *["ying"]: Expected to have been found, but missing "yang".
EOT
      assert_equal msg, out
    end
  
    def test_deep_hashes_with_surplus_elements
      @differ.diff(
        {"one" => {"foo" => "bar"}},
        {"one" => {"foo" => "bar", "baz" => "quux", "ying" => "yang"}}
      )
      msg = <<EOT
Error: Hashes of same size but with differing elements.

Expected: {"one"=>{"foo"=>"bar"}}
Got: {"one"=>{"foo"=>"bar", "baz"=>"quux", "ying"=>"yang"}}

Breakdown:
- *["one"]: Hashes of differing size (no differing elements).
  - *["baz"]: Expected to not be present, but found "quux".
  - *["ying"]: Expected to not be present, but found "yang".
EOT
      assert_equal msg, out
    end
  
    def test_deep_hashes_with_missing_elements
      @differ.diff(
        {"one" => {"foo" => "bar", "baz" => "quux", "ying" => "yang"}},
        {"one" => {"foo" => "bar"}}
      )
      msg = <<EOT
Error: Hashes of same size but with differing elements.

Expected: {"one"=>{"foo"=>"bar", "baz"=>"quux", "ying"=>"yang"}}
Got: {"one"=>{"foo"=>"bar"}}

Breakdown:
- *["one"]: Hashes of differing size (no differing elements).
  - *["baz"]: Expected to have been found, but missing "quux".
  - *["ying"]: Expected to have been found, but missing "yang".
EOT
      assert_equal msg, out
    end
  
    def test_deeper_hashes_with_variously_differing_hashes
      @differ.diff(
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
      assert_equal msg, out
    end
  
    def test_mixed_types
      @differ.diff(
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
      assert_equal msg, out
    end
  
    def xtest_collapsed_output
      @differ.diff(
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
      assert_equal msg, out
    end
  
    def xtest_custom_string_differ
    end
  
    def xtest_custom_array_differ
    end
  
    def xtest_custom_hash_differ
    end
  
    def xtest_custom_object_differ
    end
  end
end