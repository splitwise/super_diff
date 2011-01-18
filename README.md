# super_diff

## What is it?

super_diff is a utility that helps you diff two complex data structures in Ruby, and gives you helpful output to show you exactly how the two data structures differ.

## Can you give me an example?

Sure. Let's say we have two arrays. Array A looks like this:

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

We want to know what the difference is between them, so we say:

    stdout = StringIO.new
    differ = SuperDiff::Differ.new(stdout)
    differ.diff(a, b)

Differ#diff will dump some output to the stream you've given, so if we read the StringIO here, we'll get this:

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

## Why not use Diff::LCS or \<insert other tool here\>?

Because Diff::LCS really only works for arrays (as far as I know). My goal is for this to work with hashes too (or possibly other Enumerable types).

As far as other tools, I know plenty of them exist, but from the brief googling I did, I didn't get the impression that any of them are that great or really give any helpful information. But feel free to prove me wrong.
    
## Why did you make it?

For RSpec (2). Specifically the case where you're doing a simple equality test between two complex data structures:

    complex_data_structure.should == another_complex_data_structure
    
It's true that RSpec gives you a difference between the two data structures, but all it really does is call `complex_data_structure.inspect` and `another_complex_data_structure.inspect` and then run the two strings through the ubiquitous unified diff tool that's ordinarily used to find the difference between two text files, which really isn't that helpful. So I set out to solve that problem.

## So what does it do?

At the moment, it only handles basic types (strings, numbers) and arrays. I plan on handling hashes, possibly other enumerables, and possibilities like circular data structures, though. I also plan on splitting the output part of the Differ into a separate Reporter class, and making an RSpec matcher.

## Can I use it?

Sure, but keep in mind that this is really a proof-of-concept right now. I may change the API or even the name of the project. If that's okay with you, feel free to try it out.

## I've got an idea about this...

Great! I'm not really accepting issues for this, but feel free to send me a Github message or email.

## Copyright/License

&copy; 2011 Elliot Winkler. You're free to do whatever you want with the code here. You know, provided I get some sort of recognition ;)

## Contact

* **Email:** <elliot.winkler@gmail.com>
* **Twitter:** [@mcmire](http://twitter.com/mcmire)
* **Blog:** <http://lostincode.net>