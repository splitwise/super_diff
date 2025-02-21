# Introduction to SuperDiff

**SuperDiff** is a Ruby gem
which is designed to display the differences between two objects of any type
in a familiar and intelligent fashion.

The primary motivation behind this gem
is to vastly improve upon RSpec's built-in diffing capabilities.
RSpec has many nice features,
and one of them is that whenever you use a matcher such as `eq`, `match`, `include`, or `have_attributes`,
you will get a diff of the two data structures you are trying to match against.
This is great if all you want to do is compare multi-line strings.
But if you want to compare other, more "real world" kinds of values such as API or database data,
then you are out of luck.
Since [RSpec merely runs your `expected` and `actual` values through Ruby's PrettyPrinter library][rspec-differ-fail]
and then performs a diff of these strings,
the output it produces leaves much to be desired.

[rspec-differ-fail]: https://github.com/rspec/rspec/blob/rspec-support-v3.13.2/rspec-support/lib/rspec/support/differ.rb#L180-L192

For instance, let's say you wanted to compare these two hashes:

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

![Before super_diff](../assets/before.png)

What this library does
is to provide a diff engine
that knows how to figure out the differences between any two data structures
and display them in a sensible way.
So, using the example above,
you'd get this instead:

![After super_diff](../assets/after.png)
