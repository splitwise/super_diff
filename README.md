# super_diff

## What is it?

super_diff is a utility that helps you diff two complex data structures in Ruby, and gives you helpful output to show you exactly how the two data structures differ.

## Can you give me an example?

Sure. Let's say you have two arrays. Array A looks like this:

    [
      "foo",
      ["bar", ["baz", "quux"]],
      "ying",
      ["blargh", "zing", "fooz", ["raz", ["vermouth", "eee", "ffff"]]]
    ]

Array B looks like this:

    [
      "foz",
      "bar",
      "ying",
      ["blargh", "gragh", 1, ["raz", ["ralston"]], ["foreal", ["zap"]]]
    ]

You want to know what the difference is between them, so you say:

    stdout = StringIO.new
    reporter = SuperDiff::Reporter.new(stdout)
    differ = SuperDiff::Differ.new(reporter)
    differ.diff(a, b)

This will dump some output to the reporter, so if you read this output you'll get this:

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
    - *[3]: Arrays of same size but with differing elements.
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
    
## Why did you make it?

For RSpec (2). Specifically the case where you're doing a simple equality test between two complex data structures:

    complex_data_structure.should == another_complex_data_structure
    
It's true that RSpec gives you a difference between the two data structures, but all it really does is call `complex_data_structure.inspect` and `another_complex_data_structure.inspect` and then run the two strings through the ubiquitous unified diff tool that's ordinarily used to find the difference between two text files, which really isn't that helpful. So I set out to solve that problem.

## Neat! Can I use it?

Not at the moment. I'm still working on it. In fact, it doesn't work quite like the above -- it's close, but not quite. I will probably end up adding an RSpec matcher to go with it.

Anyway, if you have any ideas, I'm all ears -- my contact info is below.

## Copyright/License

&copy; 2011 Elliot Winkler. You're free to do whatever you want with the code here. You know, provided I get some sort of recognition ;)

## Contact

* **Email:** <elliot.winkler@gmail.com>
* **Twitter:** [@mcmire](http://twitter.com/mcmire)
* **Blog:** <http://lostincode.net>