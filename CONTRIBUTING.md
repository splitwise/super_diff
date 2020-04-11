# Contributing

Want to make a change to this library?
Great! Here's how you do that.

First, create a fork of this repo,
cloning it to your computer
and running the following command in the resulting directory
in order to install dependencies:

```
bin/setup
```

After this, you can run all of the tests
to make sure everything is kosher:

```
bundle exec rake
```

Next, make changes to the code as necessary.
Code is linted using Rubocop,
so make sure that's set up in your editor.
If you update one of the tests,
you can run it like so:

```
bin/rspec spec/integration/...
bin/rspec spec/unit/...
```

Finally, submit your PR.
I'll try to respond as quickly as I can.
I may have suggestions about code style or your approach,
but hopefully everything looks good and your changes get merged!
Now you're a contributor! 🎉

## Understanding the codebase

If you want to make a change
but you're having trouble where to start,
you might find the [Architecture](./ARCHITECTURE.md) document helpful.
