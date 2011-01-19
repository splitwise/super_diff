
def rubygems_require(path)
  require path
rescue LoadError => e
  require 'rubygems'
  require path
end

require 'test/unit'
require 'stringio'

rubygems_require 'differ'

require File.expand_path("../super_diff", __FILE__)

module Matchers
  # Override assert_equal to use Differ
  def assert_equal(expected, actual, message=nil)
    if String === expected && String === actual
      difference = Differ.diff_by_char(expected, actual)
      extra = "\n\nDifference:\n\n#{difference}"
    end
    full_message = build_message(message, "Expected: <#{expected.inspect}>\nGot: <#{actual.inspect}>#{extra}")
    assert_block(full_message) { expected == actual }
  end
  
  def assert_empty(value, message="Expected value to be empty, but wasn't.")
    assert value.empty?, message
  end
end

class SuperDiffTest < Test::Unit::TestCase
  include Matchers
  
  def out
    @stdout.string
  end
  
  def setup
    @stdout = StringIO.new
    @differ = SuperDiff::Differ.new(@stdout)
  end
  
  def test_equal_strings
    @differ.diff("foo", "foo")
    assert_empty out
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
  
  def test_equal_numbers
    @differ.diff(1, 1)
    assert_empty out
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
  
  def test_equal_shallow_arrays
    @differ.diff(["foo", "bar"], ["foo", "bar"])
    assert_empty out
  end
  
  def test_shallow_arrays_of_equal_size_but_differing_elements
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
  
  def test_equal_deep_arrays
    @differ.diff(
      [["foo", "bar"], ["baz", "quux"]],
      [["foo", "bar"], ["baz", "quux"]]
    )
    assert_empty out
  end
  
  def test_deep_arrays_of_equal_size_but_differing_elements
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
- *[2]: Expected to be present, but missing "baz".
- *[3]: Expected to be present, but missing "quux".
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
  - *[2]: Expected to be present, but missing "quux".
  - *[3]: Expected to be present, but missing "blargh".
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
      - *[1]: Expected to be present, but missing "eee".
      - *[2]: Expected to be present, but missing "ffff".
  - *[4]: Expected to not be present, but found ["foreal", ["zap"]].
EOT
    assert_equal msg, out
  end
end