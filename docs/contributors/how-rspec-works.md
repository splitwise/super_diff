# How RSpec works

In order to understand how the RSpec integration in SuperDiff works,
it's important to study the pieces in play within RSpec itself.

## Context

Imagine a file such as the following:

```ruby
# spec/some_spec.rb
describe "Some tests" do
  it "does something" do
    expect([1, 2, 3]).to eq([1, 6, 3])
  end
end
```

Then, imagine that the user runs:

```
rspec
```

Without SuperDiff activated,
this will produce the following output:

```
Some tests
  does something (FAILED - 1)

Failures:

  1) Some tests does something
     Failure/Error: expect([1, 2, 3]).to eq([1, 6, 3])

       expected: [1, 6, 3]
            got: [1, 2, 3]

       (compared using ==)
     # ./spec/some_spec.rb:3:in `block (2 levels) in <top (required)>'

Finished in 0.01186 seconds (files took 0.07765 seconds to load)
1 example, 1 failure

Failed examples:

rspec ./spec/some_spec.rb:2 # Some tests does something
```

Now imagine that we want to modify this output
to replace the "expected:"/"actual:" lines with a diff.
How would we do this?

## RSpec's cast of characters

First, we will review several concepts in RSpec: [^fn1]

- Since RSpec tests are "just Ruby",
  parts of tests map to objects
  which are created when those tests are loaded.
  `describe`s and `context`s are represented by
  **example groups**,
  instances of [`RSpec::Core::ExampleGroup`](https://github.com/rspec/rspec-core/blob/v3.13.0/lib/rspec/core/example_group.rb),
  and `it`s and `specify`s are represented by
  **examples**,
  instances of [`RSpec::Core::Example`](https://github.com/rspec/rspec-core/blob/v3.13.0/lib/rspec/core/example.rb).
- Most notably,
  within tests themselves,
  the `expect` method —
  [mixed into tests via the syntax layer][rspec-exp-syntax] —
  returns an instance of [`RSpec::Expectations::ExpectationTarget`](https://github.com/rspec/rspec-expectations/blob/v3.13.0/lib/rspec/expectations/expectation_target.rb),
  and may raise an error if the check it is performing fails.
- **Configuration** is kept in an instance of [`RSpec::Core::Configuration`](https://github.com/rspec/rspec-core/blob/v3.13.0/lib/rspec/core/configuration.rb),
  which is accessible via `RSpec.configuration`
  and is [initialized the first time it's used][rspec-configuration-init]
- The **runner**,
  an instance of [`RSpec::Core::Runner`](https://github.com/rspec/rspec-core/blob/v3.13.0/lib/rspec/core/runner.rb),
  is the entrypoint to all of RSpec —
  [it's called directly by the `rspec` executable][rspec-core-runner-call] —
  and executes the tests the user has specified.
- **Formatters** change RSpec's output after running tests.
  Since the user can specify one formatter when running `rspec`,
  the collection of registered formatters is managed by the formatter loader,
  an instance of [`RSpec::Core::Formatters::Loader`](https://github.com/rspec/rspec-core/blob/v3.13.0/lib/rspec/core/formatters.rb#L96).
  The default formatter is "progress",
  [set in the configuration object][rspec-default-formatter-set],
  which maps to an instance of [`RSpec::Core::Formatters::ProgressFormatter`](https://github.com/rspec/rspec-core/blob/v3.13.0/lib/rspec/core/formatters/progress_formatter.rb).
- [Notifications](https://github.com/rspec/rspec-core/blob/v3.13.0/lib/rspec/core/notifications.rb)
  represent events that occur while running tests,
  such as "these tests failed"
  or "this test was skipped".
- The **reporter**,
  an instance of [`RSpec::Core::Reporter`](https://github.com/rspec/rspec-core/blob/v3.13.0/lib/rspec/core/reporter.rb),
  acts as sort of the brain of the whole operation.
  Implementing a publish/subscribe model,
  it tracks the state of tests as they are run,
  including errors captured during the process,
  packaging key moments into notifications
  and delegating them to all registered formatters (or anything else listening to the reporter).
  Like the configuration object,
  it is also global,
  accessible via the configuration object,
  and is [initialized the first time it's used][rspec-reporter-init]
- The **exception presenter**,
  an instance of [`RSpec::Core::Formatters::ExceptionPresenter`](https://github.com/rspec/rspec-core/blob/v3.13.0/lib/rspec/core/formatters/exception_presenter.rb),
  is a special type of formatter
  which does not respond to events,
  but is rather responsible for managing all of the logic involved
  in building all of the output that appears
  when a test fails.

## What RSpec does

Given the above, RSpec performs the following sequence of events:

1. The developer adds an failing assertion to a test using the following forms
   (filling in `<actual value>`, `<matcher>`, `<block>`, and `<args...>` appropriately):
   - `expect(<actual value>).to <matcher>(<args...>)`
   - `expect { <block> }.to <matcher>(<args...>)`
   - `expect(<actual value>).not_to <matcher>(<args...>)`
   - `expect { <block> }.not_to <matcher>(<args...>)`
1. The developer runs the test using the `rspec` executable.
1. The `rspec` executable [calls `RSpec::Core::Runner.invoke`][rspec-core-runner-call].
1. Skipping a few steps, `RSpec::Core::Runner#run_specs` is called,
   which [runs all tests by surrounding them in a call to `RSpec::Core::Reporter#report`][rspec-reporter-report-call].
1. Skipping a few more steps, [`RSpec::Core::Example#run` is called to run the current example][rspec-core-example-run-call].
1. From here one of two paths is followed
   depending on whether the assertion is positive (`.to`) or negative (`.not_to`).
   - If it is positive:
     1. Within the test,
        after `expect` is called to build a `RSpec::Expectations::ExpectationTarget`,
        [the `to` method calls `RSpec::Expectations::PositiveExpectationHandler.handle_matcher`][rspec-positive-expectation-handler-handle-matcher-call].
     1. The matcher is then used to know
        whether the assertion passes or fails:
        `PositiveExpectationHandler`
        [calls the `matches?` method on the matcher][rspec-positive-expectation-handler-matcher-matches].
     1. Assuming that `matches?` returns false,
        `PositiveExpectationHandler` then [calls `RSpec::Expectations::ExpectationHelper.handle_failure`][rspec-expectation-helper-handle-failure-call-positive],
        telling it to get the positive failure message from the matcher
        by calling `failure_message`.
   - If it is negative:
     1. Within the test,
        after `expect` is called to build a `RSpec::Expectations::ExpectationTarget`,
        [the `not_to` method calls `RSpec::Expectations::NegativeExpectationHandler.handle_matcher`][rspec-negative-expectation-handler-handle-matcher-call].
     1. The matcher is then used to know
        whether the assertion passes or fails:
        `NegativeExpectationHandler`,
        [calls the `does_not_match?` method on the matcher][rspec-negative-expectation-handler-matcher-does-not-match].
     1. Assuming that `does_not_match?` returns false,
        `NegativeExpectationHandler` then [calls `RSpec::Expectations::ExpectationHelper.handle_failure`][via `NegativeExpectationHandler`][rspec-expectation-helper-handle-failure-call-negative],
        telling it to get the negative failure message from the matcher
        by calling `failure_message_when_negated`.
1. `RSpec::Expectations::ExpectationHelper.handle_failure` [calls `RSpec::Expectations.fail_with`][rspec-expectations-fail-with-call].
1. `RSpec::Expectations.fail_with` [creates a diff using `RSpec::Matchers::MultiMatcherDiff`,
   wraps it in an exception,
   and feeds the exception to `RSpec::Support.notify_failure`][rspec-support-notify-failure-call].
1. `RSpec::Support.notify_failure` calls the currently set failure notifier,
   which by default [raises the given exception][rspec-support-exception-raise].
1. Returning to `RSpec::Core::Example#run`,
   this method [rescues the exception][rspec-core-example-run-rescue]
   and then calls `finish`,
   which [calls `example_failed` on the reporter][rspec-reporter-example-failed-call].
1. `RSpec::Core::Reporter#example_failed` uses `RSpec::Core::Notifications::ExampleNotification.for`
   to [construct a notification][rspec-reporter-construct-failed-example-notification],
   which in this case is an `RSpec::Core::Notifications::FailedExampleNotification`.
   `RSpec::Core::Notifications::FailedExampleNotification` in turn
   [constructs an `RSpec::Core::Formatters::ExceptionPresenter`][rspec-exception-presenter-init].
1. `RSpec::Core::Reporter#example_failed` then [passes the notification object
   along with an event of `:example_failed` to the `notify` method][rspec-reporter-example-failed-call].
   Because `RSpec::Core::Formatters::ProgressFormatter` is a listener on the reporter,
   [its `example_failed` method gets called][rspec-progress-formatter-example-failed-call],
   which prints a message `Failure:` to the terminal.
1. Returning to `RSpec::Core::Reporter#report`,
   it now [calls `finish` after all tests are run][rspec-reporter-finish-call].
1. `RSpec::Core::Reporter#finish` [notifies listeners of the `:dump_failures` event][rspec-reporter-notify-dump-failures],
   this time using an instance of `RSpec::Core::Notifications::ExamplesNotification`.
   Again, because `RSpec::Core::Formatters::ProgressFormatter` is registered,
   its `dump_failures` method is called,
   which is actually defined in `RSpec::Core::Formatters::BaseTextFormatter`.
1. `RSpec::Core::Formatters::BaseTextFormatter#dump_failures`
   [calls `RSpec::Core::Notifications::ExamplesNotification#fully_formatted_failed_examples`][rspec-examples-notification-fully-formatted-failed-examples-call].
1. `RSpec::Core::Notifications::ExamplesNotification#fully_formatted_failed_examples`
   [formats all of the failed examples][rspec-failed-examples-notification-fully-formatted-call]
   by wrapping them in `RSpec::Core::Notifications::FailedExampleNotification`s and calling `fully_formatted` on them.
1. `RSpec::Core::Notifications::FailedExampleNotification#fully_formatted` then [calls `fully_formatted`
   on its `RSpec::Core::Formatters::ExceptionPresenter`][rspec-exception-presenter-fully-formatted-call].
1. `RSpec::Core::Formatters::ExceptionPresenter#fully_formatted` then [constructs various pieces
   of what will eventually be printed to the terminal][rspec-exception-presenter-main],
   including the name of the test,
   the line that failed,
   the error and backtrace,
   and other pertinent details.

[^fn1]: Note that the analysis of the RSpec source code in this document is accurate as of RSpec v3.13.0, released February 4, 2024.

[rspec-exp-syntax]: https://github.com/rspec/rspec-expectations/blob/v3.13.0/lib/rspec/expectations/syntax.rb#L73
[rspec-configuration-init]: https://github.com/rspec/rspec-core/blob/v3.13.0/lib/rspec/core.rb#L86
[rspec-core-runner-call]: https://github.com/rspec/rspec-core/blob/v3.13.0/exe/rspec#L4
[rspec-default-formatter-set]: https://github.com/rspec/rspec-core/blob/v3.13.0/lib/rspec/core/configuration.rb#L1030
[rspec-reporter-init]: https://github.com/rspec/rspec-core/blob/v3.13.0/lib/rspec/core/configuration.rb#L1056
[rspec-reporter-report-call]: https://github.com/rspec/rspec-core/blob/v3.13.0/lib/rspec/core/runner.rb#L115
[rspec-core-example-run-call]: https://github.com/rspec/rspec-core/blob/v3.13.0/lib/rspec/core/example_group.rb#L646
[rspec-positive-expectation-handler-handle-matcher-call]: https://github.com/rspec/rspec-expectations/blob/v3.13.0/lib/rspec/expectations/expectation_target.rb#L65
[rspec-negative-expectation-handler-handle-matcher-call]: https://github.com/rspec/rspec-expectations/blob/v3.13.0/lib/rspec/expectations/expectation_target.rb#L78
[rspec-positive-expectation-handler-matcher-matches]: https://github.com/rspec/rspec-expectations/blob/v3.13.0/lib/rspec/expectations/handler.rb#L51
[rspec-negative-expectation-handler-matcher-does-not-match]: https://github.com/rspec/rspec-expectations/blob/v3.13.0/lib/rspec/expectations/handler.rb#L79
[rspec-expectation-helper-handle-failure-call-positive]: https://github.com/rspec/rspec-expectations/blob/v3.13.0/lib/rspec/expectations/handler.rb#L56
[rspec-expectation-helper-handle-failure-call-negative]: https://github.com/rspec/rspec-expectations/blob/v3.13.0/lib/rspec/expectations/handler.rb#L84
[rspec-expectations-fail-with-call]: https://github.com/rspec/rspec-expectations/blob/v3.13.0/lib/rspec/expectations/handler.rb#L37-L41
[rspec-support-notify-failure-call]: https://github.com/rspec/rspec-expectations/blob/v3.13.0/lib/rspec/expectations/fail_with.rb#L27-L35
[rspec-support-exception-raise]: https://github.com/rspec/rspec-support/blob/v3.13.0/lib/rspec/support.rb#L110
[rspec-core-example-run-rescue]: https://github.com/rspec/rspec-core/blob/v3.13.0/lib/rspec/core/example.rb#L280
[rspec-reporter-example-failed-call]: https://github.com/rspec/rspec-core/blob/v3.13.0/lib/rspec/core/example.rb#L484
[rspec-reporter-construct-failed-example-notification]: https://github.com/rspec/rspec-core/blob/v3.13.0/lib/rspec/core/notifications.rb#L52
[rspec-exception-presenter-init]: https://github.com/rspec/rspec-core/blob/v3.13.0/lib/rspec/core/notifications.rb#L213
[rspec-reporter-example-failed-call]: https://github.com/rspec/rspec-core/blob/v3.13.0/lib/rspec/core/reporter.rb#L145
[rspec-progress-formatter-example-failed-call]: https://github.com/rspec/rspec-core/blob/v3.13.0/lib/rspec/core/reporter.rb#L209
[rspec-reporter-finish-call]: https://github.com/rspec/rspec-core/blob/v3.13.0/lib/rspec/core/reporter.rb#L76
[rspec-reporter-notify-dump-failures]: https://github.com/rspec/rspec-core/blob/v3.13.0/lib/rspec/core/reporter.rb#L178
[rspec-examples-notification-fully-formatted-failed-examples-call]: https://github.com/rspec/rspec-core/blob/v3.13.0/lib/rspec/core/formatters/base_text_formatter.rb#L32
[rspec-failed-examples-notification-fully-formatted-call]: https://github.com/rspec/rspec-core/blob/v3.13.0/lib/rspec/core/notifications.rb#L114
[rspec-exception-presenter-fully-formatted-call]: https://github.com/rspec/rspec-core/blob/v3.13.0/lib/rspec/core/notifications.rb#L202
[rspec-exception-presenter-main]: https://github.com/rspec/rspec-core/blob/v3.13.0/lib/rspec/core/formatters/exception_presenter.rb#L84-L100
