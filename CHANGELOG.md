# Changelog

## 0.4.2 - 2020-02-11

### Bug fixes

* Fix `raise_error` when used with a regex. ([#72])

[#72]: https://github.com/mcmire/super_diff/pull/72

## 0.4.1 - 2020-01-30

### Bug fixes

* Fix multiple exception failures so that they work again. ([#66])

[v0.4.1]: https://github.com/mcmire/super_diff/tree/v0.4.1
[#66]: https://github.com/mcmire/super_diff/pull/66

## 0.4.0 - 2020-01-16

### Features

* Support `match_array` matcher.
* Support `has_*` matcher.
* Be smarter about highlighting first line of failure message.
* Fix diffing of ActiveRecord objects in nested objects.

### Improvements

* Remove explicit dependency on ActiveRecord. ([#64])

[#64]: https://github.com/mcmire/super_diff/pull/64

## 0.3.0 - 2019-12-17

### Features

* Add useful diff representation of Time-like values. ([#61])
* Fix tests so they run even with a global `--color` setting. ([#62])

[#61]: https://github.com/mcmire/super_diff/pull/61
[#62]: https://github.com/mcmire/super_diff/pull/62

## 0.2.0 - 2019-10-04

Lots of fixes and new features!

### Features

* Fix how objects are displayed in diff output:
  * Fix output of diffs so that objects are deeply pretty printed.
  * Use Object#inspect as a fallback for single-line object inspection.
* Support diffing ordinary, "non-custom" objects (those that do *not* respond to
  `attributes_for_super_diff`).
* Add custom coloring/messaging to `include` matcher.
* Support pretty-printing `a_hash_including` objects and diffing them with
  hashes.
* Support pretty-printing `a_collection_including` objects and diffing them with
  arrays.
* Add custom coloring/messaging to `have_attributes` matcher.
* Support pretty-printing `an_object_having_attributes` objects and diffing them
  with other objects.
* Add a key/legend to the diff output so it's less confusing.
* Add custom coloring/messaging to `respond_to` matcher.
* Add custom coloring/messaging to `raise_error` matcher.
* Fix output from diff between a multi-line string with a single-line (and vice
  versa).
* Make sure that RSpec double objects are pretty-printed correctly Add custom
  coloring/messaging to `contain_exactly`.
* Support pretty-printing `a_collection_containing_exactly` objects and diffing
  them with other arrays.
* Add support for diffing ActiveRecord models.
* Add support for diffing ActiveRecord::Relation objects with arrays.
* Fix output for diff between two completely different kinds of objects
* Support pretty-printing HashWithIndifferentAccess objects and diffing them
  with hashes.
* Detect and handle recursive data structures.
* Automatically disable color output when running tests non-interactively (e.g.
  on a CI service).
* Add custom coloring/messaging to `be_*` matcher.
* Fix representation of empty arrays, hashes, and objects in diffs so that they
  are always on single lines.
* Change colors in diffs and messages from red/green to magenta/yellow.
* Use bold to highlight "Failure/Error" instead of white so that output looks
  good on a light terminal color scheme
* Fix coloring for unhandled errors so that the whole message isn't colored in
  red, but only the first line.

## 0.1.0 - 2019-10-02

Initial version!

### Features

* Support diffing primitives.
* Support diffing strings (single-line and multi-line).
* Support diffing arrays (simple and complex).
* Support diffing "custom objects" (i.e. objects that respond to
  `attributes_for_super_diff`).
* Add basic integration with RSpec.
