# Changelog

## 0.9.0 - 2022-04-25

### Fixes

- Fix diff produced when comparing two floats (e.g. `expect(value).to eq(1.0)`)
  so that it does not blow up with a NoMethodError ([#146])

### Features

- Make `SuperDiff::VERSION` accessible without requiring `super_diff/version`
  ([#147])

[#146]: https://github.com/mcmire/super_diff/pull/146
[#147]: https://github.com/mcmire/super_diff/pull/147

## 0.8.0 - 2021-05-14

### BREAKING CHANGES

- Diff formatters are now gone in favor of operation tree flatteners. If you
  have a custom diff formatter, you will want to inherit from
  SuperDiff::OperationTreeFlatteners::Base (or an appropriate subclass).
  Additionally, the `add_extra_diff_formatter_class` configuration option has
  disappeared; instead, operation tree classes are expected to have an
  `operation_tree_flattener_class` method, which should return your custom
  operation tree flattener class. ([#91])

### Features

- Add the ability to compress long diffs by eliding sections of unchanged data
  (data which is present in both "expected" and "actual" values). This
  functionality is not enabled by default; rather, you will need to activate it.
  At a minimum, you will want to add this to your spec helper (or a support file
  if you so desire):

  ```ruby
  SuperDiff.configure { |config| config.diff_elision_enabled = true }
  ```

  By default the elision will be pretty aggressive, but if you want to preserve
  more of the unchanged lines in the diff, you can set `diff_elision_maximum`:

  ```ruby
  SuperDiff.configure do |config|
    config.diff_elision_enabled = true
    config.diff_elision_maximum = 10
  end
  ```

  Here, the gem will try to keep at least 10 unchanged lines in between changed
  lines.

  ([#91])

### Features

- Update inspection of Doubles to include stubbed methods and their values.
  ([#91])

### Improvements

- Change how objects are inspected on a single line so that instance variables
  are always sorted. ([#91])
- Make a tweak to how hashes are presented in diffs and inspections: a hash that
  has a mixture of symbols and strings will be presented as though all keys are
  strings (i.e. hashrocket syntax). ([#91])

[#91]: https://github.com/mcmire/super_diff/pull/91

## 0.7.0 - 2021-05-07

### Features

- Add support for `hash_including`, `array_including`, `kind_of`, and
  `instance_of`, which come from `rspec-mocks`. ([#128])

- Update how Time-like values are displayed in diffs to include subseconds
  so that it is easy to tell the difference between two times that are extremely
  close to each other. ([#130])

[#128]: https://github.com/mcmire/super_diff/pull/128
[#130]: https://github.com/mcmire/super_diff/pull/130

### Fixes

- Fix comparison involving hashes to prevent a case where the same key would
  show up twice in the diff (one as a "deleted" version and another as an
  "unchanged" version). ([#129])

[#129]: https://github.com/mcmire/super_diff/pull/129

## 0.6.2 - 2021-04-16

### Improvements

- Rename SuperDiff::ObjectInspection.inspect to something less collision-y
  so that it can be inspected in IRB sessions. ([#123])

- Silence warnings. ([#124])

[#123]: https://github.com/mcmire/super_diff/pull/123
[#124]: https://github.com/mcmire/super_diff/pull/124

## 0.6.1 - 2021-02-10

### Fixes

- Fix compatibility issues with newer versions of `rspec-rails` which prevented
  the gem from being loaded. ([#121])

[#121]: https://github.com/mcmire/super_diff/pull/121

## 0.6.0 - 2021-02-07

### Features

- You can now customize the colors that SuperDiff uses by adding this to your
  test setup:

  ```ruby
  SuperDiff.configure do |config|
    config.actual_color = :green
    config.expected_color = :red
    config.border_color = :yellow
    config.header_color = :yellow
  end
  ```

  ([#107], [042e8ec])

- Ruby 3.0 is now supported. ([#118])

[#107]: https://github.com/mcmire/super_diff/pull/107
[042e8ec]: https://github.com/mcmire/super_diff/commit/042e8ecda282cd8a3d436b3bf2c0aded76187db2
[#118]: https://github.com/mcmire/super_diff/pull/118

### Fixes

- Resolve compatibility issues with RSpec 3.10. ([#114])
- Fix diffs involving `contain_exactly` and `a_collection_containing_exactly`
  so that if there are extra items in the actual value, they are shown with
  `+`s. ([#106])

[#114]: https://github.com/mcmire/super_diff/pull/114
[#106]: https://github.com/mcmire/super_diff/pull/106

### Other notable changes

- Fix reliability issues with CI.
- Fix `rake spec` so that it works when run locally again.

## 0.5.3 - 2020-12-21

### Fixes

- Fix `match_array` so that it works when given a string. ([#110])

[#110]: https://github.com/mcmire/super_diff/pull/110

### Improvements

- Include the license in the gemspec so that it is visible via tools such as
  `license_finder`. ([#111])

[#111]: https://github.com/mcmire/super_diff/pull/111

## 0.5.2 - 2020-09-04

### Fixes

- Add missing standard library requires. ([#98])

[#98]: https://github.com/mcmire/super_diff/pull/98

### Other notable changes

- Drop support for Ruby 2.4.

## 0.5.1 - 2020-06-19

### Fixes

- Add dependency on `attr_extras` back as it was mistakenly removed in the
  previous release. ([#92])

[#92]: https://github.com/mcmire/super_diff/pull/92

## 0.5.0 - 2020-06-18

### BREAKING CHANGES

- Do some reorganizing and rename some concepts in the code: "operational
  sequencer" changes to "operation tree builder" and "operation sequence"
  changes to "operation tree". Although super_diff is not yet at 1.0, this does
  result in breaking changes to the API, so:

  - If you are inheriting from `SuperDiff::OperationalSequencers::*`, you will
    want to now inherit from `SuperDiff::OperationTreeBuilders::*`.
  - If you are inheriting from `SuperDiff::OperationSequence::*`, you will
    want to now inherit from `SuperDiff::OperationTrees::*`.
  - If you are configuring the gem by saying:

    ```ruby
    SuperDiff::RSpec.configuration do |config|
      config.add_extra_operational_sequencer_class(SomeClass)
      config.add_extra_operation_sequence_class(SomeClass)
    end
    ```

    you will want to change this to:

    ```ruby
    SuperDiff::RSpec.configuration do |config|
      config.add_extra_operation_tree_builder_class(SomeClass)
      config.add_extra_operation_tree_class(SomeClass)
    end
    ```

  ([#84], [#85])

[#84]: https://github.com/mcmire/super_diff/pull/84
[#85]: https://github.com/mcmire/super_diff/pull/85

### Features

- Add inspectors for `an_instance_of`, `a_kind_of`, and `a_value_within`.
  ([#74])

[#74]: https://github.com/mcmire/super_diff/pull/74

### Fixes

- Get rid of warnings produced on Ruby 2.7.1. ([#71])
- Fix diff produced by (incorrect) usage of `have_attributes` with a hash as the
  actual value. ([#76])

[#71]: https://github.com/mcmire/super_diff/pull/71
[#76]: https://github.com/mcmire/super_diff/pull/76

### Improvements

- Move configuration so that instead of using

  ```ruby
  SuperDiff::RSpec.configure do |config|
    # ...
  end
  ```

  you can now say:

  ```ruby
  SuperDiff.configure do |config|
    # ...
  end
  ```

  ([#80])

- Update diff between two hashes so that original ordering of keys is preserved.
  ([#81])

[#80]: https://github.com/mcmire/super_diff/pull/81
[#81]: https://github.com/mcmire/super_diff/pull/81

## 0.4.2 - 2020-02-11

### Fixes

- Fix `raise_error` when used with a regex. ([#72])

[#72]: https://github.com/mcmire/super_diff/pull/72

## 0.4.1 - 2020-01-30

### Fixes

- Fix multiple exception failures so that they work again. ([#66])

[#66]: https://github.com/mcmire/super_diff/pull/66

## 0.4.0 - 2020-01-16

### Features

- Support `match_array` matcher.
- Support `has_*` matcher.
- Be smarter about highlighting first line of failure message.
- Fix diffing of ActiveRecord objects in nested objects.

### Improvements

- Remove explicit dependency on ActiveRecord. ([#64])

[#64]: https://github.com/mcmire/super_diff/pull/64

## 0.3.0 - 2019-12-17

### Features

- Add useful diff representation of Time-like values. ([#61])
- Fix tests so they run even with a global `--color` setting. ([#62])

[#61]: https://github.com/mcmire/super_diff/pull/61
[#62]: https://github.com/mcmire/super_diff/pull/62

## 0.2.0 - 2019-10-04

Lots of fixes and new features!

### Features

- Fix how objects are displayed in diff output:
  - Fix output of diffs so that objects are deeply pretty printed.
  - Use Object#inspect as a fallback for single-line object inspection.
- Support diffing ordinary, "non-custom" objects (those that do _not_ respond to
  `attributes_for_super_diff`).
- Add custom coloring/messaging to `include` matcher.
- Support pretty-printing `a_hash_including` objects and diffing them with
  hashes.
- Support pretty-printing `a_collection_including` objects and diffing them with
  arrays.
- Add custom coloring/messaging to `have_attributes` matcher.
- Support pretty-printing `an_object_having_attributes` objects and diffing them
  with other objects.
- Add a key/legend to the diff output so it's less confusing.
- Add custom coloring/messaging to `respond_to` matcher.
- Add custom coloring/messaging to `raise_error` matcher.
- Fix output from diff between a multi-line string with a single-line (and vice
  versa).
- Make sure that RSpec double objects are pretty-printed correctly Add custom
  coloring/messaging to `contain_exactly`.
- Support pretty-printing `a_collection_containing_exactly` objects and diffing
  them with other arrays.
- Add support for diffing ActiveRecord models.
- Add support for diffing ActiveRecord::Relation objects with arrays.
- Fix output for diff between two completely different kinds of objects
- Support pretty-printing HashWithIndifferentAccess objects and diffing them
  with hashes.
- Detect and handle recursive data structures.
- Automatically disable color output when running tests non-interactively (e.g.
  on a CI service).
- Add custom coloring/messaging to `be_*` matcher.
- Fix representation of empty arrays, hashes, and objects in diffs so that they
  are always on single lines.
- Change colors in diffs and messages from red/green to magenta/yellow.
- Use bold to highlight "Failure/Error" instead of white so that output looks
  good on a light terminal color scheme
- Fix coloring for unhandled errors so that the whole message isn't colored in
  red, but only the first line.

## 0.1.0 - 2019-10-02

Initial version!

### Features

- Support diffing primitives.
- Support diffing strings (single-line and multi-line).
- Support diffing arrays (simple and complex).
- Support diffing "custom objects" (i.e. objects that respond to
  `attributes_for_super_diff`).
- Add basic integration with RSpec.
