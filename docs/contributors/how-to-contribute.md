# How to Contribute

Want to make a change to this project?
Great! Here's how you do that.

## 1. Install dependencies

First, [create a fork of the SuperDiff repo](https://github.com/splitwise/super_diff/fork)
and clone it to your computer.

Next, run the following command in the resulting directory
in order to install dependencies.
This will also install a Git hook
which ensures all code is formatted whenever a commit is pushed:

```
bin/setup
```

## 2. Make a new branch

It's best to follow [GitHub Flow][github-flow] when working on this repo.
Start by making a new branch to hold your changes:

```
git checkout -b <name of your branch>
```

[github-flow]: https://docs.github.com/en/get-started/using-github/github-flow

## 3. Understand the codebase

Some architectural documents have been provided
to aid you in understanding the codebase.
You might find the guide on [how SuperDiff works](./architecture/how-super-diff-works.md) to be helpful, for example.

## 4. Write and run tests

All code is backed by tests,
so if you want to submit a pull request,
make sure to update the existing tests or write new ones as you find necessary.

There are two kinds of tests in this project:

- **Unit tests**, kept in `spec/unit`,
  exercise individual classes and methods in isolation.
- **Integration tests**, kept in `spec/integration`,
  exercise the interaction between SuperDiff, RSpec, and parts of Rails.

It's best to run all of the tests after cloning SuperDiff
to establish a baseline for any changes you want to make,
but you can also run them at any time:

```
bundle exec rake
```

If you want to run one of the tests, say:

```
bin/rspec spec/integration/...
bin/rspec spec/unit/...
```

Note that the integration tests
can be quite slow to run.
If you'd like to speed them up,
run the following command in a separate terminal session:

```
zeus start
```

Now the next time you run an integration test by saying

```
bin/rspec spec/integration/...
```

it should run twice as fast.

## 5. Run the linter

Code is linted and formatted using Rubocop.
so [make sure that's set up in your editor][rubocop-editors].
If you don't want to do this,
you can also fix any lint violations by running:

```
bundle exec rubocop -a
```

Provided that you ran `bin/setup` above,
any code you've changed will also be linted
whenever you push a commit.

[rubocop-editors]: https://docs.rubocop.org/rubocop/integration_with_other_tools.html#editor-integration

## 6. (Optional) Update the documentation

If there's any part of this documentation that you wish to update,
then in a free terminal session, run:

```
poetry run mkdocs serve
```

Now open `http://localhost:8000` to view a preview of the documentation locally.

The files themselves are located in `docs/`
and are written in Markdown.
Thanks to the command above,
updating any of these files will automatically be reflected in the preview.

## 7. Submit a pull request

When you're done,
push your branch
and create a new pull request.
I'll try to respond as quickly as I can.
I may have suggestions about code style or your approach,
but hopefully everything looks good and your changes get merged!
Now you're a contributor! 🎉
