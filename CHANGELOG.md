# Changelog

## [Unreleased]

### Other changes

- Add max major version constraints to dependencies. [#296](https://github.com/splitwise/super_diff/pull/296)
- Remove unused `syntax_tree` gems from development. [#297](https://github.com/splitwise/super_diff/pull/297)
- Simplify tiered lines elider. [#302](https://github.com/splitwise/super_diff/pull/302)

## 0.18.0 - 2025-12-05

### Features

- Abbreviate ActionDispatch::Request inspection. [#294](https://github.com/splitwise/super_diff/pull/294)

## 0.17.0 - 2025-10-24

### Features

- Add official Ruby 3.4 support. [#289](https://github.com/splitwise/super_diff/pull/289) by [@olleolleolle](https://github.com/olleolleolle)

### Bug fixes

- Fix hash diffing algorithm. [#293](https://github.com/splitwise/super_diff/pull/293)

### Other changes

- Fix bundler gem caching in CI. [#289](https://github.com/splitwise/super_diff/pull/289) by [@olleolleolle](https://github.com/olleolleolle)

## 0.16.0 - 2025-06-17

### Breaking changes

- Dropped support for Ruby 3.0, which reached EOL in April 2024. [#280](https://github.com/splitwise/super_diff/pull/280)

### Features

- Add official Rails 7.1 support. [#278](https://github.com/splitwise/super_diff/pull/278)
- Add official Rails 7.2 support. [#279](https://github.com/splitwise/super_diff/pull/279)
- Add official Rails 8.0 support. [#281](https://github.com/splitwise/super_diff/pull/281)

### Bug fixes

- Fix ActiveRecord's `attributes_for_super_diff` and tree builders related to Active Records to handle models that do not have a primary key.
  [#282](https://github.com/splitwise/super_diff/pull/282) by [@atranson-electra](https://github.com/atranson-electra)
- Fix failure case for chained matchers. [#288](https://github.com/splitwise/super_diff/pull/288)

### Other changes

- Fix `logger` dependency issues in CI. [#277](https://github.com/splitwise/super_diff/pull/277)
- Updated permalink to rspec differ in README.md [#258](https://github.com/splitwise/super_diff/pull/276) by [@sealocal](https://github.com/sealocal)
- Tweak `sqlite3` and `appraisal` dev dependencies. [#287](https://github.com/splitwise/super_diff/pull/287)

## 0.15.0 - 2025-01-06

### Features

- Implement RSpec 3.13.0+ compatibility. [#258](https://github.com/splitwise/super_diff/pull/258)

### Other changes

- Filter super_diff from RSpec backtrace. [#275](https://github.com/splitwise/super_diff/pull/275) by [@FlorinPopaCodes](https://github.com/FlorinPopaCodes)

## 0.14.0 - 2024-11-15

### Features

- Improve inspection of Module. [#263](https://github.com/splitwise/super_diff/pull/263) by [@phorsuedzie](https://github.com/phorsuedzie)
- Fix multiline string diff with blank lines. [#266](https://github.com/splitwise/super_diff/pull/266)
- Improve inspection of Range objects. [#267](https://github.com/splitwise/super_diff/pull/267) by [@lucaseras](https://github.com/lucaseras)
- Skip diffing of more un-diffable types. [#273](https://github.com/splitwise/super_diff/pull/273) by [@lucaseras](https://github.com/lucaseras)

### Other changes

- Switch from Prettier to Rubocop. [#269](https://github.com/splitwise/super_diff/pull/269)
- Fix outdated reference in documentation. [#270](https://github.com/splitwise/super_diff/pull/270) by [@emmanuel-ferdman](https://github.com/emmanuel-ferdman)
- Replace Zeus with forking strategy for tests. [#271](https://github.com/splitwise/super_diff/pull/271)

## 0.13.0 - 2024-09-22

### Features

- Add better support for Data object diffing. [#259](https://github.com/splitwise/super_diff/pull/259)
- Fall back on RSpec color mode when `SuperDiff.configuration.color_enabled` is unspecified or nil. [#261](https://github.com/splitwise/super_diff/pull/261)

### Breaking changes

- Removed several `SuperDiff::Csi` methods. This will break any code that uses those parts of the `SuperDiff::Csi` (which is private in general).
- `SuperDiff.configuration.color_enabled = nil` used to disable color output. It now allows SuperDiff to determine whether to colorize output based on the environment (namely RSpec color mode and whether stdout is a TTY).

## 0.12.1 - 2024-04-26

Note that since 0.12.0 has been yanked, changes for this version are listed
alongside changes for 0.12.1. Also, changelog entries that were mistakenly
omitted for 0.12.0 are included below as well.

### Features

- Create a proper space for docs, add info on architecture, and deploy docs
  to a docsite automatically.
  ([#224](https://github.com/splitwise/super_diff/pull/224),
  [#225](https://github.com/splitwise/super_diff/pull/225),
  [#226](https://github.com/splitwise/super_diff/pull/226),
  [#232](https://github.com/splitwise/super_diff/pull/232),
  [#233](https://github.com/splitwise/super_diff/pull/233),
  [#245](https://github.com/splitwise/super_diff/pull/245))
  - The `docs/` directory now holds information on contributing, which was
    previously located at `CONTRIBUTING.md`, as well as information on using the
    gem, which was previously located in `README.md`.
  - However, crucially, `docs/` also now includes a breakdown of how this
    project is structured and how the diffing engine works. This is hopefully
    helpful to people who want to submit changes to this project.
  - Additionally, starting with this release, the Markdown files in `docs/` will
    published to a docsite, which can be viewed at
    <https://splitwise.github.io/super_diff>.
  - Publishing of the docsite is automated: when a new release is issued, a new
    version of the docsite will be published for that release under
    <https://splitwise.github.io/super_diff/releases/RELEASE_VERSION>.
    (<https://splitwise.github.io/super_diff> will always redirect to the latest
    release.)
  - If any file in `docs/` is modified in a pull request, a new version of the
    docsite will also be automatically deployed just for that pull request,
    located under
    <https://splitwise.github.io/super_diff/branches/BRANCH_NAME/COMMIT_ID>.
- Support the use of primary keys other than `id` when diffing ActiveRecord
  models. ([#237](https://github.com/splitwise/super_diff/pull/237))

### Bug fixes

- Remove rogue `pp` statement
  ([#242](https://github.com/splitwise/super_diff/pull/242))

### Other notable changes

- Reorganize codebase ([#230](https://github.com/splitwise/super_diff/pull/230))
  - To be able to explain the architecture of this project more easily,
    differs, inspection tree builders, operation tree builders, operation tree
    flatteners, and operation trees for Ruby have now been relocated under a
    `Basic` feature module, located in `lib/super_diff/basic`, which mirrors
    `lib/super_diff/active_record`, `lib/super_diff/active_support`, and
    `lib/super_diff/rspec`.
  - Additionally, all of the files that were previously in `lib/super_diff` have
    been moved to a `Core` module, and to make the file structure a little
    flatter, `InspectionTreeBuilders` in various feature modules have been
    removed from the `ObjectInspection` namespace.
  - To maintain backward compatibility, all of the original constants still
    exist, but they've been deprecated, and attempting to use them will result
    in a warning. They will be removed in a future version.
  - For full transparency, here is the list of renames:
    - The following constants that were previously available under `SuperDiff`
      are now located under `SuperDiff::Core`:
      - `ColorizedDocumentExtensions`
      - `Configuration`
      - `GemVersion`
      - `Helpers`
      - `ImplementationChecks`
      - `Line`
      - `RecursionGuard`
      - `TieredLines`
      - `TieredLinesElider`
      - `TieredLinesFormatter`
    - Everything under `SuperDiff::Differs` is now under
      `SuperDiff::Basic::Differs`
    - All error classes under `SuperDiff::Errors` have been moved out and are
      now directly under `SuperDiff::Core`
    - `SuperDiff::ObjectInspection::InspectionTree` is now
      `SuperDiff::Core::InspectionTree`
    - Everything under `SuperDiff::ObjectInspection::InspectionTreeBuilders` is
      now under `SuperDiff::Core::InspectionTreeBuilders`
    - Everything under `SuperDiff::ObjectInspection::Nodes` is now under
      `SuperDiff::Core::InspectionTreeNodes`
    - Everything under `SuperDiff::OperationTreeBuilders` is now under
      `SuperDiff::Basic::OperationTreeBuilders`
    - Everything under `SuperDiff::OperationTreeFlatteners` is now under
      `SuperDiff::Basic::OperationTreeFlatteners`
    - Everything under `SuperDiff::OperationTrees` is now under
      `SuperDiff::Basic::OperationTrees`
    - Everything under `SuperDiff::Operations` has been moved out and is now
      directly under `SuperDiff::Core`
    - Everything under
    - `SuperDiff::ActiveRecord::ObjectInspection::InspectionTreeBuilders` is now
      under `SuperDiff::ActiveRecord::InspectionTreeBuilders`
    - Everything under
    - `SuperDiff::ActiveSupport::ObjectInspection::InspectionTreeBuilders` is
      now under `SuperDiff::ActiveSupport::InspectionTreeBuilders`
    - Everything under
    - `SuperDiff::RSpec::ObjectInspection::InspectionTreeBuilders` is now under
      `SuperDiff::RSpec::InspectionTreeBuilders`

### Contributors

This release features the following contributors:

- [@benk-gc](https://github.com/benk-gc)
- [@sidane](https://github.com/sidane)

Thank you!

## 0.12.0 - 2024-04-24 [YANKED]

> [!WARNING]
> This release has been yanked, as it included changes that weren't properly
> logged in the changelog. This release wasn't ideal as it contained some
> leftover print statements, anyway.

### Features

- Support the use of primary keys other than `id` when diffing ActiveRecord
  models. ([#237](https://github.com/splitwise/super_diff/pull/237))

### Contributors

This release features the following contributors:

- [@benk-gc](https://github.com/benk-gc)

Thank you!

## 0.11.0 - 2024-02-10

### BREAKING CHANGES

- Change InspectionTree so that it no longer `instance_eval`s the block it
  takes. ([#210](https://github.com/splitwise/super_diff/issues/210))
  - If you have a custom InspectionTreeBuilder, you will need to change your
    `call` method so that instead of looking like this:
    ```ruby
    def call
      SuperDiff::ObjectInspection::InspectionTree.new do
        as_lines_when_rendering_to_lines(collection_bookend: :open) do
          add_text object.inspect
        end
      end
    end
    ```
    it looks something like this instead:
    ```ruby
    def call
      SuperDiff::ObjectInspection::InspectionTree.new do |t1|
        t1.as_lines_when_rendering_to_lines(collection_bookend: :open) do |t2|
          t2.add_text object.inspect
        end
      end
    end
    ```
    Note that the following methods yield a new InspectionTree, so the tree
    needs to be given a new name each time. It is conventional to use `t1`,
    `t2`, etc.:
    - `as_lines_when_rendering_to_lines`
    - `as_prefix_when_rendering_to_lines`
    - `as_prelude_when_rendering_to_lines`
    - `as_single_line`
    - `nested`
    - `only_when`
    - `when_empty`
    - `when_non_empty`
    - `when_rendering_to_lines`
    - `when_rendering_to_string`

### Features

- Add inspector for RSpec describable matchers not otherwise handled by an
  explicit inspector. ([#203](https://github.com/splitwise/super_diff/issues/203),
  [#219](https://github.com/splitwise/super_diff/issues/219))
- Support diffing date-like objects, e.g. `Date` vs. `Date` or `Date` vs.
  `DateTime`. ([#198](https://github.com/splitwise/super_diff/issues/198))

### Fixes

- Add inspector for ActiveSupport::OrderedOptions.
  ([#199](https://github.com/splitwise/super_diff/issues/199))
  - This prevents the gem from raising an error when the expected value is a
    Rails response object, e.g. `expect(response).to be_forbidden`.
- Include `extra_failure_lines` from RSpec metadata in failure output.
  ([#208](https://github.com/splitwise/super_diff/issues/208))
- Fix `match_array` so that it truly accepts a non-array argument, to match
  RSpec behavior. ([#213](https://github.com/splitwise/super_diff/issues/213))
- Fix `raise_error` so that it accepts an RSpec matcher argument.
  ([#214](https://github.com/splitwise/super_diff/issues/214))

### Improvements

- Improve wording in `raise_error` failure messages.
  ([#218](https://github.com/splitwise/super_diff/issues/218))

### Contributors

This release features the following contributors:

- [@jas14](https://github.com/jas14)
- [@willnet](https://github.com/willnet)
- [@fizvlad](https://github.com/fizvlad)
- [@wata727](https://github.com/wata727)

Thank you!

## 0.10.0 - 2023-03-26

### BREAKING CHANGES

- Drop support for Ruby 2.5, 2.6, and 2.7 as well as Rails 5.0, 5.1, and 5.2,
  as they have reached (or are about to reach) end-of-life. To use this gem,
  you must use at least Ruby 3.x, and if you're using Rails, Rails 6.x. ([#187],
  [#190])

### Fixes

- Fix diffing logic for `include` matcher so that it knows how to compare fuzzy
  matcher objects with other kinds of objects. ([#156])
- Add a `key_enabled` configuration option for disabling the key/legend in the
  diff output. ([#166])
- Add a `color_enabled` configuration option for disabling color. ([#138])
- Update `super_diff/rails` (and, by extension, `super_diff/rspec-rails`) so
  that the ActiveRecord-specific integration isn't loaded if ActiveRecord isn't
  available. ([#188])

[#187]: https://github.com/splitwise/super_diff/pull/187
[#190]: https://github.com/splitwise/super_diff/pull/190
[#156]: https://github.com/splitwise/super_diff/pull/156
[#166]: https://github.com/splitwise/super_diff/pull/166
[#138]: https://github.com/splitwise/super_diff/pull/138
[#188]: https://github.com/splitwise/super_diff/pull/188

## 0.9.0 - 2022-04-25

### Fixes

- Fix diff produced when comparing two floats (e.g. `expect(value).to eq(1.0)`)
  so that it does not blow up with a NoMethodError ([#146])

### Features

- Make `SuperDiff::VERSION` accessible without requiring `super_diff/version`
  ([#147])

[#146]: https://github.com/splitwise/super_diff/pull/146
[#147]: https://github.com/splitwise/super_diff/pull/147

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

- Update inspection of Doubles to include stubbed methods and their values.
  ([#91])

### Improvements

- Change how objects are inspected on a single line so that instance variables
  are always sorted. ([#91])
- Make a tweak to how hashes are presented in diffs and inspections: a hash that
  has a mixture of symbols and strings will be presented as though all keys are
  strings (i.e. hashrocket syntax). ([#91])

[#91]: https://github.com/splitwise/super_diff/pull/91

## 0.7.0 - 2021-05-07

### Features

- Add support for `hash_including`, `array_including`, `kind_of`, and
  `instance_of`, which come from `rspec-mocks`. ([#128])

- Update how Time-like values are displayed in diffs to include subseconds
  so that it is easy to tell the difference between two times that are extremely
  close to each other. ([#130])

[#128]: https://github.com/splitwise/super_diff/pull/128
[#130]: https://github.com/splitwise/super_diff/pull/130

### Fixes

- Fix comparison involving hashes to prevent a case where the same key would
  show up twice in the diff (one as a "deleted" version and another as an
  "unchanged" version). ([#129])

[#129]: https://github.com/splitwise/super_diff/pull/129

## 0.6.2 - 2021-04-16

### Improvements

- Rename SuperDiff::ObjectInspection.inspect to something less collision-y
  so that it can be inspected in IRB sessions. ([#123])

- Silence warnings. ([#124])

[#123]: https://github.com/splitwise/super_diff/pull/123
[#124]: https://github.com/splitwise/super_diff/pull/124

## 0.6.1 - 2021-02-10

### Fixes

- Fix compatibility issues with newer versions of `rspec-rails` which prevented
  the gem from being loaded. ([#121])

[#121]: https://github.com/splitwise/super_diff/pull/121

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

[#107]: https://github.com/splitwise/super_diff/pull/107
[042e8ec]: https://github.com/splitwise/super_diff/commit/042e8ecda282cd8a3d436b3bf2c0aded76187db2
[#118]: https://github.com/splitwise/super_diff/pull/118

### Fixes

- Resolve compatibility issues with RSpec 3.10. ([#114])
- Fix diffs involving `contain_exactly` and `a_collection_containing_exactly`
  so that if there are extra items in the actual value, they are shown with
  `+`s. ([#106])

[#114]: https://github.com/splitwise/super_diff/pull/114
[#106]: https://github.com/splitwise/super_diff/pull/106

### Other notable changes

- Fix reliability issues with CI.
- Fix `rake spec` so that it works when run locally again.

## 0.5.3 - 2020-12-21

### Fixes

- Fix `match_array` so that it works when given a string. ([#110])

[#110]: https://github.com/splitwise/super_diff/pull/110

### Improvements

- Include the license in the gemspec so that it is visible via tools such as
  `license_finder`. ([#111])

[#111]: https://github.com/splitwise/super_diff/pull/111

## 0.5.2 - 2020-09-04

### Fixes

- Add missing standard library requires. ([#98])

[#98]: https://github.com/splitwise/super_diff/pull/98

### Other notable changes

- Drop support for Ruby 2.4.

## 0.5.1 - 2020-06-19

### Fixes

- Add dependency on `attr_extras` back as it was mistakenly removed in the
  previous release. ([#92])

[#92]: https://github.com/splitwise/super_diff/pull/92

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

[#84]: https://github.com/splitwise/super_diff/pull/84
[#85]: https://github.com/splitwise/super_diff/pull/85

### Features

- Add inspectors for `an_instance_of`, `a_kind_of`, and `a_value_within`.
  ([#74])

[#74]: https://github.com/splitwise/super_diff/pull/74

### Fixes

- Get rid of warnings produced on Ruby 2.7.1. ([#71])
- Fix diff produced by (incorrect) usage of `have_attributes` with a hash as the
  actual value. ([#76])

[#71]: https://github.com/splitwise/super_diff/pull/71
[#76]: https://github.com/splitwise/super_diff/pull/76

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

[#80]: https://github.com/splitwise/super_diff/pull/81
[#81]: https://github.com/splitwise/super_diff/pull/81

## 0.4.2 - 2020-02-11

### Fixes

- Fix `raise_error` when used with a regex. ([#72])

[#72]: https://github.com/splitwise/super_diff/pull/72

## 0.4.1 - 2020-01-30

### Fixes

- Fix multiple exception failures so that they work again. ([#66])

[#66]: https://github.com/splitwise/super_diff/pull/66

## 0.4.0 - 2020-01-16

### Features

- Support `match_array` matcher.
- Support `has_*` matcher.
- Be smarter about highlighting first line of failure message.
- Fix diffing of ActiveRecord objects in nested objects.

### Improvements

- Remove explicit dependency on ActiveRecord. ([#64])

[#64]: https://github.com/splitwise/super_diff/pull/64

## 0.3.0 - 2019-12-17

### Features

- Add useful diff representation of Time-like values. ([#61])
- Fix tests so they run even with a global `--color` setting. ([#62])

[#61]: https://github.com/splitwise/super_diff/pull/61
[#62]: https://github.com/splitwise/super_diff/pull/62

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
