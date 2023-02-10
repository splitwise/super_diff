# SuperDiff [![Gem Version][version-badge]][rubygems] [![Build Status][gh-actions-badge]][gh-actions] ![Downloads][downloads-badge] [![IssueHunt][issuehunt-badge]][issuehunt]

[version-badge]: http://img.shields.io/gem/v/super_diff.svg
[rubygems]: http://rubygems.org/gems/super_diff
[gh-actions-badge]: https://img.shields.io/github/actions/workflow/status/mcmire/super_diff/super_diff.yml?branch=master
[downloads-badge]: http://img.shields.io/gem/dtv/super_diff.svg
[hound]: https://houndci.com
[issuehunt-badge]: https://img.shields.io/badge/sponsored_through-IssueHunt-2EC28C
[issuehunt]: https://issuehunt.io/r/mcmire/super_diff

SuperDiff is a gem that hooks into RSpec
to intelligently display the differences between two data structures of any type.

📢 **[See what's changed in recent versions.][changelog]**

[changelog]: CHANGELOG.md

## Introduction

The primary motivation behind this gem
is to vastly improve upon RSpec's built-in diffing capabilities.

Sometimes, whenever you use a matcher such as `eq`, `match`, `include`, or `have_attributes`,
you will get a diff of the two data structures you are trying to match against.
This is great if all you want to do is compare multi-line strings.
But if you want to compare other, more "real world" kinds of values,
such as what you might work with when developing API endpoints
or testing methods that make database calls and return a set of model objects,
then you are out of luck.
Since [RSpec merely runs your `expected` and `actual` values through Ruby's PrettyPrinter library][rspec-differ-fail]
and then performs a diff of these strings,
the output it produces leaves much to be desired.

[rspec-differ-fail]: https://github.com/rspec/rspec-support/blob/c69a231d7369dd165ad7ce4742e1a2e21e3462b5/lib/rspec/support/differ.rb#L178

For instance,
let's say you wanted to compare these two hashes:

```ruby
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
    { name: "Fender Stratocaster", cost: 100_000, options: %w[red blue green] },
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
    { name: "Fender Stratocaster", cost: 100_000, options: %w[red blue green] },
    { name: "Chevy 4x4" }
  ]
}
```

If, somewhere in a test, you were to say:

```ruby
expect(actual).to eq(expected)
```

You would get output that looks like this:

![Before super_diff](docs/before.png)

What this library does
is to provide a diff engine
that knows how to figure out the differences between any two data structures
and display them in a sensible way.
So, using the example above,
you'd get this instead:

![After super_diff](docs/after.png)

## Installation

There are a few different ways to install `super_diff`
depending on your type of project.

### Rails apps

If you're developing a Rails app,
add the following to your Gemfile:

```ruby
group :test do
  gem "super_diff"
end
```

After running `bundle install`,
add the following to your `rails_helper`:

```ruby
require "super_diff/rspec-rails"
```

### Projects using some part of Rails (e.g. ActiveModel)

If you're developing an app using Hanami or Sinatra,
or merely using a part of Rails such as ActiveModel,
add the following to your Gemfile where appropriate:

```ruby
gem "super_diff"
```

After running `bundle install`,
add the following to your `spec_helper`:

```ruby
require "super_diff/rspec"
require "super_diff/active_support"
```

### Gems

If you're developing a gem,
add the following to your gemspec:

```ruby
spec.add_development_dependency "super_diff"
```

Now add the following to your `spec_helper`:

```ruby
require "super_diff/rspec"
```

## Configuration

You can customize the behavior of the gem
by adding a configuration block
to your test helper file
(`rails_helper` or `spec_helper`)
which looks something like this:

```ruby
SuperDiff.configure do |config|
  # ...
end
```

### Customizing colors

If you don't like the colors that SuperDiff uses,
you can change them like this:

```ruby
SuperDiff.configure do |config|
  config.actual_color = :green
  config.expected_color = :red
  config.border_color = :yellow
  config.header_color = :yellow
end
```

See [eight_bit_color.rb](lib/super_diff/csi/eight_bit_color.rb)
for the list of available colors.

You can also completely disable colorized output.

<!-- prettier-ignore-start -->
```ruby
SuperDiff.configure do |config|
  config.color_enabled = false
  end
```
<!-- prettier-ignore-end -->

### Disabling the key

You can disable the key by changing the following config (default: true):

<!-- prettier-ignore-start -->
```ruby
SuperDiff.configure do |config|
  config.key_enabled = false
end
```
<!-- prettier-ignore-end -->

### Hiding unimportant lines

When looking at a large diff for which many of the lines do not change,
it can be difficult to locate the lines which do. Text-oriented
diffs such as those you get from a conventional version control system
solve this problem by removing those unchanged lines from the diff
entirely. The same can be done in SuperDiff.

```ruby
SuperDiff.configure do |config|
  config.diff_elision_enabled = false
  config.diff_elision_maximum = 3
end
```

- `diff_elision_enabled` — The elision logic is disabled by default so
  as not to surprise people, so setting this to `true` will turn it on.
- `diff_elision_maximum` — This number controls what happens to
  unchanged lines (i.e. lines that are neither "insert" lines nor
  "delete" lines) that are in between changed lines. If a section of
  unchanged lines is beyond this number, the gem will elide (a fancy
  word for remove) the data structures within that section as much as
  possible until the limit is reached or it cannot go further. Elided
  lines are replaced with a `# ...` marker.

### Diffing custom objects

If you are comparing two data structures
that involve a class that is specific to your project,
the resulting diff may not look as good as diffs involving native or primitive objects.
This happens because if SuperDiff doesn't recognize a class,
it will fall back to a generic representation when diffing instances of that class.
Fortunately, the gem has a pluggable interface
that allows you to insert your own implementations
of key pieces involved in the diffing process.
I'll have more about how that works soon,
but here is what such a configuration would look like:

```ruby
SuperDiff.configure do |config|
  config.add_extra_differ_class(YourDiffer)
  config.add_extra_operation_tree_builder_class(YourOperationTreeBuilder)
  config.add_extra_operation_tree_class(YourOperationTree)
end
```

## Support

My goal for this library is to improve your development experience.
If this is not the case,
and you encounter a bug or have a suggestion,
feel free to [create an issue][issues-list].
I'll try to respond to it as soon as I can!

[issues-list]: https://github.com/mcmire/super_diff/issues

## Contributing

Any code contributions to improve this library are welcome!
Please see the [contributing](./CONTRIBUTING.md) document for more on how to do that.

## Sponsoring

If there's a change you want implemented, you can choose to sponsor that change!
`super_diff` is set up on IssueHunt,
so feel free to search for an existing issue (or make your own)
and [add a bounty](https://issuehunt.io/r/mcmire/super_diff).
I'll get notified right away!

## Compatibility

`super_diff` is [tested][gh-actions] to work with
Ruby >= 2.5.x,
RSpec 3.x,
and Rails >= 5.x.

[gh-actions]: https://github.com/mcmire/super_diff/actions?query=workflow%3ASuperDiff

## Inspiration/Thanks

In developing this gem
I made use of or was heavily inspired by these libraries:

- [Diff::LCS][diff-lcs],
  the library I started with in the [original version of this gem][original-version]
  (made in 2011!)
- The pretty-printing algorithms and API within [PrettyPrinter][pretty-printer] and [AwesomePrint][awesome-print],
  from which I borrowed ideas to develop the [inspectors][inspection-tree].

Thank you to the authors of these libraries!

[original-version]: https://github.com/mcmire/super_diff/tree/old-master
[diff-lcs]: https://github.com/halostatue/diff-lcs
[pretty-printer]: https://github.com/ruby/ruby/tree/master/lib/prettyprint.rb
[awesome-print]: https://github.com/awesome-print/awesome_print
[inspection-tree]: https://github.com/mcmire/super_diff/blob/master/lib/super_diff/object_inspection/inspection_tree.rb

## Author/License

SuperDiff was created and is maintained by Elliot Winkler.
It is released under the [MIT license](LICENSE).
