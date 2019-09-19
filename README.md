# SuperDiff [![Gem Version][version-badge]][rubygems] [![Build Status][travis-badge]][travis] ![Downloads][downloads-badge] [![Hound][hound-badge]][hound]

[version-badge]: http://img.shields.io/gem/v/super_diff.svg
[rubygems]: http://rubygems.org/gems/super_diff
[travis-badge]: http://img.shields.io/travis/mcmire/super_diff/master.svg
[downloads-badge]: http://img.shields.io/gem/dtv/super_diff.svg
[hound-badge]: https://img.shields.io/badge/Reviewed_by-Hound-8E64B0.svg
[hound]: https://houndci.com

SuperDiff is a Ruby gem that intelligently displays the differences between two
data structures of any type.

📢 **[See what's changed in the latest version (0.1.0)][changelog].**

[changelog]: CHANGELOG.md

## Introduction

The primary motivation behind this gem is to replace RSpec's built-in diffing
capabilities. Sometimes, whenever you use a matcher such as `eq`, `match`,
`include`, or `have_attributes`, you will get a diff of the two data structures
you are trying to match against. This is really helpful for strings, but not so
helpful for other, more "real world" kinds of values, such as arrays, hashes,
and full-scale objects. The reason this doesn't work is because [all RSpec does
is run your `expected` and `actual` values through Ruby's PrettyPrinter
library][rspec-differ-fail] and then perform a diff of these strings.

For instance, let's say you wanted to compare these two hashes:

``` ruby
actual = {
  customer: {
    person: SuperDiff::Test::Person.new(name: "Marty McFly, Jr.", age: 17),
    shipping_address: {
      line_1: "456 Ponderosa Ct.",
      city: "Hill Valley",
      state: "CA",
      zip: "90382"
    }
  },
  items: [
    {
      name: "Fender Stratocaster",
      cost: 100_000,
      options: ["red", "blue", "green"]
    },
    { name: "Mattel Hoverboard" }
  ]
}

expected = {
  customer: {
    person: SuperDiff::Test::Person.new(name: "Marty McFly", age: 17),
    shipping_address: {
      line_1: "123 Main St.",
      city: "Hill Valley",
      state: "CA",
      zip: "90382"
    }
  },
  items: [
    {
      name: "Fender Stratocaster",
      cost: 100_000,
      options: ["red", "blue", "green"]
    },
    { name: "Chevy 4x4" }
  ]
}
```

If, somewhere in a test, you were to say:

``` ruby
expect(actual).to eq(expected)
```

You would get output that looks like:

![Before super_diff](doc/before_super_diff.png)

Not great.

This library provides a diff engine that knows how to figure out the differences
between any two data structures and display them in a sensible way. Using the
example above, you'd get this instead:

![After super_diff](doc/after_super_diff.png)

[rspec-differ-fail]: https://github.com/rspec/rspec-support/blob/c69a231d7369dd165ad7ce4742e1a2e21e3462b5/lib/rspec/support/differ.rb#L178

## Installation

Want to try out this gem for yourself? As with most development-related gems,
there are a couple ways depending on your type of project:

### Rails apps

If you're developing a Rails app, add the following to your Gemfile:

``` ruby
gem "super_diff"
```

After running `bundle install`, add the following to your `rails_helper`:

``` ruby
require "super_diff/rspec-rails"
```

You're done!

### Libraries

If you're developing a library, add the following to your gemspec:

``` ruby
spec.add_development_dependency "super_diff"
```

Now add the following to your `spec_helper`:

``` ruby
require "super_diff/rspec"
```

You're done!

## Configuration

As capable as this library is, it doesn't know how to deal with every kind of
object out there. You might find it necessary to instruct the gem on how to diff
your object. To do this, you can use a configuration block. Simply add this to
your test helper file (either `rails_helper` or `spec_helper`):

``` ruby
SuperDiff::RSpec.configure do |config|
  config.add_extra_differ_class(YourDiffer)
  config.add_extra_operational_sequencer_class(YourOperationalSequencer)
  config.add_extra_diff_formatter_class(YourDiffFormatter)
end
```

*(More info here in the future on adding a custom differ, operational sequencer,
and diff formatter. Also explanations on what these are.)*

## Contributing

If you encounter a bug or have an idea for how this could be better, feel free
to [create an issue](https://github.com/mcmire/super_diff/issues).

If you'd like to submit a PR instead, here's how to get started. First, fork
this repo. Then, when you've cloned your fork, run:

```
bundle install
```

This will install various dependencies. After this, you can run all of the
tests: 

```
bundle exec rake
```

Or a single test:

```
bundle exec rspec spec/acceptance/...
bundle exec rspec spec/unit/...
```

Finally, submit your PR and I'll take a look at it when I get a chance.

## Compatibility

`super_diff` is [tested][travis] to work with Ruby >= 2.4.x, RSpec 3.x, and
Rails >= 5.x.

[travis]: http://travis-ci.org/mcmire/super_diff

## Inspiration/Thanks

In developing this gem I made use of or was heavily inspired by these libraries:

* [Diff::LCS][diff-lcs], the library I started with in the [original version of
  this gem][original-version] (made in 2011!)
* The pretty-printing algorithms and API within [PrettyPrinter][pretty-printer]
  and [AwesomePrint][awesome-print], from which I borrowed ideas to develop
  the [inspectors][inspection-tree].

Thank you so much!

[original-version]: https://github.com/mcmire/super_diff/tree/old-master
[diff-lcs]: https://github.com/halostatue/diff-lcs
[pretty-printer]: https://github.com/ruby/ruby/tree/master/lib/prettyprint.rb
[awesome-print]: https://github.com/awesome-print/awesome_print
[inspection-tree]: https://github.com/mcmire/super_diff/blob/master/lib/super_diff/object_inspection/inspection_tree.rb

## Copyright/License

© 2018-2019 Elliot Winkler, released under the [MIT license](LICENSE).
