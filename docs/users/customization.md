# Customizing SuperDiff

You can customize the behavior of the gem
by opening your test helper file
(`spec/rails_helper.rb` or `spec/spec_helper.rb`)
and calling `SuperDiff.configure` with a configuration block:

```ruby
SuperDiff.configure do |config|
  # ...
end
```

The following is a list of options you can set on the configuration object
along with their defaults:

| name                   | description                                                                           | default    |
| ---------------------- | ------------------------------------------------------------------------------------- | ---------- |
| `actual_color`         | The color used to display "actual" values in diffs                                    | `:yellow`  |
| `border_color`         | The color used to display the border in diff keys                                     | `:blue`    |
| `color_enabled`        | Whether to colorize output, or `nil` to let SuperDiff decide based on the environment | `nil`      |
| `diff_elision_enabled` | Whether to elide (remove) unchanged lines in diff                                     | `false`    |
| `diff_elision_maximum` | How large a section of consecutive unchanged lines can be before being elided         | `0`        |
| `elision_marker_color` | The color used to display the marker substituted for elided lines in a diff           | `:cyan`    |
| `expected_color`       | The color used to display "expected" values in diffs                                  | `:magenta` |
| `header_color`         | The color used to display the "Diff:" header in failure messages                      | `:white`   |
| `key_enabled`          | Whether to show the key above diffs                                                   | `true`     |

The following is a list of methods you can call on the configuration object:

| name                                        | description                                                         |
| ------------------------------------------- | ------------------------------------------------------------------- |
| `add_extra_diff_formatter_classes`          | Additional classes with which to format diffs                       |
| `add_extra_differ_classes`                  | Additional classes with which to compute diffs for objects          |
| `add_extra_inspection_tree_builder_classes` | Additional classes used to inspect objects                          |
| `add_extra_operation_tree_builder_classes`  | Additional classes used to build operation trees for objects        |
| `add_extra_operation_tree_classes`          | Additional classes used to hold operations in diffs between objects |

Read on for more information about available kinds of customizations.

### Customizing colors

If you don't like the colors that SuperDiff uses,
you can change them like so:

```ruby
SuperDiff.configure do |config|
  config.actual_color = :green
  config.expected_color = :red
  config.border_color = :yellow
  config.header_color = :yellow
end
```

See `CSI::EightBitColor` in the codebase
for the list of available colors you can use as values here.

You can also completely disable colorized output:

```ruby
SuperDiff.configure { |config| config.color_enabled = false }
```

### Disabling the key

By default, when a diff is displayed,
a key appears above it.
This key serves to clarify
which colors and symbols belong to the "expected" and "actual" values.
However, you can disable the key as follows:

```ruby
SuperDiff.configure { |config| config.key_enabled = false }
```

### Hiding unchanged lines

When looking at a large diff made up of many lines that do not change,
it can be difficult to make out the lines that do.
Text-oriented diffs,
such as those you get from a conventional version control system,
solve this problem by removing or "eliding" those unchanged lines from the diff entirely.
The same can be done in SuperDiff.

For instance, the following configuration enables diff elision
and ensures that within a block of unchanged lines,
a maximum of only 3 lines are displayed:

```ruby
SuperDiff.configure do |config|
  config.diff_elision_enabled = true
  config.diff_elision_maximum = 3
end
```

A diff in which some lines are elided may look like this:

```diff
  [
    # ...
    "American Samoa",
    "Andorra",
-   "Angola",
+   "Anguilla",
    "Antarctica",
    "Antigua And Barbuda",
    # ...
  ]
```

as opposed to:

```diff
  [
    "Afghanistan",
    "Aland Islands",
    "Albania",
    "Algeria",
    "American Samoa",
    "Andorra",
-   "Angola",
+   "Anguilla",
    "Antarctica",
    "Antigua And Barbuda",
    "Argentina",
    "Armenia",
    "Aruba",
    "Australia"
  ]
```

### Diffing custom objects

If you are comparing two instances of a class
which are specific to your project,
the resulting diff may not look as good
as diffs involving native or primitive objects.
This happens because if SuperDiff doesn't recognize a class,
it will fall back to a generic representation for the diff.

There are two ways to solve this problem.

#### Adding an `attributes_for_super_diff` method

This is the easiest approach.
If two objects have this method,
SuperDiff will use the hash that this method returns to compare those objects
and will compute a diff between them,
which will show up in the output.

##### Example

For instance, say we have the following classes:

```ruby
class Http
  # ...
end

class Order
  def initialize(id, number)
    @id = id
    @number = number
  end
end

class OrderRequestor
  def initialize(order)
    @order = order
    @http_library = Http.new
  end

  def request
    @http_library.get("/orders/#{order.id}")
  end
end

class OrderTracker
  def initialize(order)
    @order = order
    @requestor = OrderRequestor.new(order)
  end
end
```

and we have two instances of these class as follows:

```ruby
actual = OrderTracker.new(Order.new(id: 1, number: "1000"))
expected = OrderTracker.new(Order.new(id: 2, number: "2000"))
```

If we diff these two objects,
then we will see something like:

```diff
  #<OrderTracker:0x111111111 {
-   @order=#<Order:0x222222222 {
-     id: 2,
-     number: '2000'
-   }>,
-   @requestor=#<OrderRequestor:0x333333333 {
-     @order=#<Order:0x222222222 {
-       id: 2,
-       number: '2000'
-     }>,
-     @http_library=#<Http:0x444444444 {
-     }>
-   }>
+   @order=#<Order:0x555555555 {
+     id: 1,
+     number: '1000'
+   }>,
+   @requestor=#<OrderRequestor:0x666666666 {
+     @order=#<Order:0x555555555 {
+       id: 1,
+       number: '1000'
+     }>,
+     @http_library=#<Http:0x777777777 {
+     }>
+   }>
  }>
```

It is not difficult to see that this diff is fairly noisy.
It would be good if we could exclude `requestor`,
since it's a bit redundant,
and it would help if we could collapse some of the lines as well.
We also don't need to know the address of each object
(the `0xXXXXXXXXX` bit).

We can easily solve this
by adding an `attributes_for_super_diff` method to OrderTracker,
making sure to exclude `requestor`,
and by adding a similar method to Order as well.

```diff
  class Order
    def initialize(id, number)
      @id = id
      @number = number
    end
+
+   def attributes_for_super_diff
+     { id: @id, number: @number }
+   end
  end

  class OrderTracker
    def initialize(order)
      @order = order
      @requestor = OrderRequestor.new(order)
    end
+
+   def attributes_for_super_diff
+     { order: @order }
+   end
  end
```

If we performed another diff, we would now get:

```diff
  #<OrderTracker {
    order: #<Order {
-     id: 2,
+     id: 1,
-     number: '2000'
+     number: '1000'
-   }>
  }>
```

#### Registering new building blocks

This approach is more advanced,
but also offers the greatest flexibility.

More information will be added here on how to do this,
but in the meantime,
the best example is the [RSpec integration](https://github.com/splitwise/super_diff/blob/v0.11.0/lib/super_diff/rspec.rb#L91) in SuperDiff itself.
