# SuperDiff [![Gem Version][version-badge]][rubygems] [![Build Status][travis-badge]][travis] ![Downloads][downloads-badge] [![Hound][hound-badge]][hound]

[version-badge]: http://img.shields.io/gem/v/super_diff.svg
[rubygems]: http://rubygems.org/gems/super_diff
[travis-badge]: http://img.shields.io/travis/mcmire/super_diff/master.svg
[travis]: http://travis-ci.org/mcmire/super_diff
[downloads-badge]: http://img.shields.io/gem/dtv/super_diff.svg
[hound-badge]: https://img.shields.io/badge/Reviewed_by-Hound-8E64B0.svg
[hound]: https://houndci.com

## Concept

SuperDiff is a utility that helps you diff two complex data structures in Ruby
and gives you helpful output to show you exactly how the two data structures
differ.

Let's say you have two hashes and you want to compare them. Perhaps your first
hash looks like this:

``` ruby
expected = {
  customer: {
    name: "Marty McFly",
    shipping_address: {
      line_1: "123 Main St.",
      city: "Hill Valley",
      state: "CA",
      zip: "90382",
    },
  },
  items: [
    {
      name: "Fender Stratocaster",
      cost: 100_000,
      options: ["red", "blue", "green"],
    },
    { name: "Chevy 4x4" },
  ],
}
```

and your second hash looks like this:

``` ruby
actual = {
  customer: {
    name: "Marty McFly, Jr.",
    shipping_address: {
      line_1: "456 Ponderosa Ct.",
      city: "Hill Valley",
      state: "CA",
      zip: "90382",
    },
  },
  items: [
    {
      name: "Fender Stratocaster",
      cost: 100_000,
      options: ["red", "blue", "green"],
    },
    { name: "Mattel Hoverboard" },
  ],
}
```

If you want to know what the difference between them is, you could say:

``` ruby
SuperDiff::EqualityMatcher.call(expected, actual)
```

This will give you the following string:

```
Differing hashes.

Expected: { customer: { name: "Marty McFly", shipping_address: { line_1: "123 Main St.", city: "Hill Valley", state: "CA", zip: "90382" } }, items: [{ name: "Fender Stratocaster", cost: 100000, options: ["red", "blue", "green"] }, { name: "Chevy 4x4" }] }
Got: { customer: { name: "Marty McFly, Jr.", shipping_address: { line_1: "456 Ponderosa Ct.", city: "Hill Valley", state: "CA", zip: "90382" } }, items: [{ name: "Fender Stratocaster", cost: 100000, options: ["red", "blue", "green"] }, { name: "Mattel Hoverboard" }] }

Diff:

  {
    customer: {
-     name: "Marty McFly",
+     name: "Marty McFly, Jr.",
      shipping_address: {
-       line_1: "123 Main St.",
+       line_1: "456 Ponderosa Ct.",
        city: "Hill Valley",
        state: "CA",
        zip: "90382"
      }
    },
    items: [
      {
        name: "Fender Stratocaster",
        cost: 100000,
        options: ["red", "blue", "green"]
      },
      {
-       name: "Chevy 4x4"
+       name: "Mattel Hoverboard"
      }
    ]
  }
```

When printed to a terminal, this will display in color, so the "expected" value
in the summary and deleted lines in the diff will appear in red, while the
"actual" value in the summary and inserted lines in the diff will appear in
green.

By the way, SuperDiff doesn't just work with hashes, but arrays as well as other
objects, too!

## Usage

There are two ways to use this gem. One way is to use the API methods that this
gem provides, such as the method presented above.

However, this gem was really designed for use specifically with RSpec. In recent
years, RSpec has added a feature where if you're comparing two objects in a test
and your test fails, you will see a diff between those objects (provided the
objects are large enough). However, this diff is not always the most helpful.
It's very common when writing tests for API endpoints to work with giant JSON
hashes, and RSpec's diffs are not sufficient in highlighting changes between
such structures. Therefore, this gem provides an integration layer where you can
replace RSpec's differ with SuperDiff.

To get started, add the gem to your Gemfile under the `test` group:

``` ruby
gem "super_diff"
```

Then, open up `spec_helper` and add this line somewhere:

``` ruby
require "super_diff/rspec"
```

Now try writing a test using `eq` to compare two large data structures, and you
should see a diff similar to the one given above.

## Contributing

If you encounter a bug or have an idea for how this could be better, I'm all
ears! Feel free to create an issue.

If you'd like to submit a PR instead, here's how to get started. First, fork
this repo and then run:

```
bundle install
```

This will install dependencies. From here you can run all of the tests:

```
bundle exec rake
```

Or a single test:

```
bundle exec rspec spec/acceptance/...
bundle exec rspec spec/unit/...
```

Finally, submit your PR and I'll take a look at it when I get a chance.

## Copyright/License

© 2018 Elliot Winkler, released under the [MIT license](LICENSE).
