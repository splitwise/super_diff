# Architecture

I'll have more later around this,
but here are some quick hits:

## Basic concepts

* A **differ** figures out which operational sequencer to use.
* An **operational sequencer** makes a comparison between two like data structures.
  and generates a set of operations between them
  (additions, deletions, or changes).
* An **operation sequence** is a list of those operations
  associated with some kind of diff formatter.
* A **diff formatter** takes a list of operations
  and spits out a textual representation of that list in the form of a conventional diff.
* An **object inspector** generates a multi-line textual representation of an object,
  similar to PrettyPrinter in Ruby or AwesomePrint,
  but more appropriate for showing within a diff.

## Code flow diagram

[![code flow](./docs/code-flow-diagram.png)](https://docs.google.com/drawings/d/1nKi4YKXgzzIIM-eY0P4uwjkglmuwlf8nTRFne8QZhBg/edit)
