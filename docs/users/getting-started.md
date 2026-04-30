# Getting Started

SuperDiff is designed to be used different ways, depending on the type of project.

## Using SuperDiff with RSpec in a Rails app

If you're developing a Rails app,
run the following command to add SuperDiff to your project:

```bash
bundle add super_diff --group test
```

Then add the following toward the top of `spec/rails_helper.rb`:

```ruby
require "super_diff/rspec-rails"
```

At this point, you can write tests for parts of your app,
and SuperDiff will be able to diff Rails-specific objects
such as ActiveRecord models,
ActionController response objects,
instances of HashWithIndifferentAccess, etc.,
in addition to objects that ship with RSpec,
such as matchers.

You can now continue on to [customizing SuperDiff](./customization.md).

## Using SuperDiff with RSpec in a project using parts of Rails

If you're developing an app using Hanami or Sinatra,
or merely using a part of Rails such as ActiveModel,
run the following command to add SuperDiff to your project:

```bash
bundle add super_diff
```

After running `bundle install`,
add the following toward the top of `spec/spec_helper.rb`:

```ruby
require "super_diff/rspec"
```

Then, add one or all of the following lines:

```ruby
require "super_diff/active_support"
require "super_diff/active_record"
```

At this point, you can write tests for parts of your app,
and SuperDiff will be able to diff objects depending on which path you required.
For instance, if you required `super_diff/active_support`,
then SuperDiff will be able to diff objects defined in ActiveSupport,
such as HashWithIndifferentAccess,
and if you required `super_diff/active_record`,
it will be able to diff ActiveRecord models.
In addition to these,
it will also be able to diff objects that ship with RSpec,
such as matchers.

You can now continue on to [customizing SuperDiff](./customization.md).

## Using SuperDiff with RSpec in a Ruby project

If you're developing a library or other project
that does not depend on any part of Rails,
run the following command to add SuperDiff to your project:

```bash
bundle add super_diff
```

Now add the following toward the top of `spec/spec_helper.rb`:

```ruby
require "super_diff/rspec"
```

At this point, you can write tests for parts of your app,
and SuperDiff will be able to diff objects that ship with RSpec,
such as matchers.

You can now continue on to [customizing SuperDiff](./customization.md).

## Binary Strings

SuperDiff can diff binary strings (`Encoding::ASCII_8BIT`) using a hex-dump
format and a binary-safe inspection label.
To enable this, add:

```ruby
require "super_diff/binary_string"
```

You can create binary strings with `String#b` or by forcing the encoding.

## Using parts of SuperDiff directly

Although SuperDiff is primarily designed to integrate with RSpec,
it can also be used on its own in other kinds of applications.

First, install the gem:

```bash
bundle add super_diff
```

Then, require it somewhere:

```ruby
require "super_diff"
```

If you want to compare two objects and display a friendly diff,
you can use the equality matcher interface:

```ruby
SuperDiff::EqualityMatchers::Main.call(expected, actual)
```

Or, if you want to compare two objects and get a lower-level list of operations,
you can use the differ interface:

```ruby
SuperDiff::Differs::Main.call(expected, actual)
```
