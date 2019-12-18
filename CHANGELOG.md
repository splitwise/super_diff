# Changelog

## [0.3.0 (2019-12-17)][v0.3.0]

[v0.3.0]: https://github.com/mcmire/super_diff/tree/v0.3.0

* Add useful diff representation of Time-like values
  [[#61][issue-61]]
  ([@Mange][mange])
* Fix tests so they run even with a global `--color` setting
  [[#62][issue-62]]

[issue-61]: https://github.com/mcmire/super_diff/pull/61
[issue-62]: https://github.com/mcmire/super_diff/pull/62
[mange]: https://github.com/Mange

## [0.2.0 (2019-10-04)][v0.2.0]

[v0.2.0]: https://github.com/mcmire/super_diff/tree/v0.2.0

Lots of fixes and new features!

* Fix how objects are displayed in diff output:
  * Fix output of diffs so that objects are deeply pretty printed
  * Use Object#inspect as a fallback for single-line object inspection
* Support diffing ordinary, "non-custom" objects
  (those that do *not* respond to `attributes_for_super_diff`)
* Add custom coloring/messaging to `include` matcher
* Support pretty-printing `a_hash_including` objects
  and diffing them with hashes
* Support pretty-printing `a_collection_including` objects
  and diffing them with arrays
* Add custom coloring/messaging to `have_attributes` matcher
* Support pretty-printing `an_object_having_attributes` objects
  and diffing them with other objects
* Add a key/legend to the diff output so it's less confusing
* Add custom coloring/messaging to `respond_to` matcher
* Add custom coloring/messaging to `raise_error` matcher
* Fix output from diff between a multi-line string with a single-line
  (and vice versa)
* Make sure that RSpec double objects are pretty-printed correctly
* Add custom coloring/messaging to `contain_exactly`
* Support pretty-printing `a_collection_containing_exactly` objects
  and diffing them with other arrays
* Add support for diffing ActiveRecord models
* Add support for diffing ActiveRecord::Relation objects with arrays
* Fix output for diff between two completely different kinds of objects
* Support pretty-printing HashWithIndifferentAccess objects
  and diffing them with hashes
* Detect and handle recursive data structures
* Automatically disable color output when running tests non-interactively
  (e.g. on a CI service)
* Add custom coloring/messaging to `be_*` matcher
* Fix representation of empty arrays, hashes, and objects in diffs
  so that they are always on single lines
* Change colors in diffs and messages
  from red/green to magenta/yellow
* Use bold to highlight "Failure/Error" instead of white
  so that output looks good on a light terminal color scheme
* Fix coloring for unhandled errors
  so that the whole message isn't colored in red,
  but only the first line

## [0.1.0 (2019-10-02)][v0.1.0]

[v0.1.0]: https://github.com/mcmire/super_diff/tree/v0.1.0

Initial version!

* Support diffing primitives
* Support diffing strings (single-line and multi-line)
* Support diffing arrays (simple and complex)
* Support diffing "custom objects"
  (i.e. objects that respond to `attributes_for_super_diff`)
* Add basic integration with RSpec
