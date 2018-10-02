# SuperDiff [![Gem Version][version-badge]][rubygems] [![Build Status][travis-badge]][travis] ![Downloads][downloads-badge] [![Hound][hound-badge]][hound]

[version-badge]: http://img.shields.io/gem/v/super_diff.svg
[rubygems]: http://rubygems.org/gems/super_diff
[travis-badge]: http://img.shields.io/travis/mcmire/super_diff/master.svg
[travis]: http://travis-ci.org/mcmire/super_diff
[downloads-badge]: http://img.shields.io/gem/dtv/super_diff.svg
[hound-badge]: https://img.shields.io/badge/Reviewed_by-Hound-8E64B0.svg
[hound]: https://houndci.com

SuperDiff is a utility that helps you diff two complex data structures in Ruby,
and gives you helpful output to show you exactly how the two data structures
differ.

## Installation

Add the following line to your Gemfile:

    gem "super_diff"

## Usage

Let's say you have two hashes and you want to compare them. Perhaps your first
hash looks like this:

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

and your second hash looks like this:

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

If you want to know what the difference between them is, you could say:

    require "super_diff"

    puts SuperDiff::EqualityMatcher.call(expected, actual)

This will print out the following:

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

This works with arrays, too!

## Usage with RSpec

This gem was specifically designed for use with RSpec. RSpec has this great
feature where if you're using `eq` or some other built-in matcher to compare two
objects, and your test fails, you may see a diff between those objects. However,
this diff is not always the most helpful. It's very common when writing tests
for API endpoints to work with large data structures, and these diffs are not
sufficient in highlighting changes between such structures.

To fix this, this gem replaces the default differ in RSpec with SuperDiff so
that you get diffs such as the example provided above. To make use of this,
simply add this line to your `spec_helper`:

    require "super_diff/rspec"

## Contributing

If you encounter a bug or have an idea for how this could be better, I'm all
ears! Feel free to create an issue or post a PR and I'll take a look at it when
I get a chance.

To get set up locally, clone this repo and then run:

    bundle install

This will install dependencies. From here you can run all of the tests:

    bundle exec rake

## Copyright/License

© 2018 Elliot Winkler, released under the [MIT license](LICENSE).
