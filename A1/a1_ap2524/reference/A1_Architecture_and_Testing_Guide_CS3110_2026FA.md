# A1: Architecture and Testing Guide

Use this guide in two passes. During Task 1, Step 1, skim the project-architecture material through **What Belongs in `bin`**. Return to the Cram material in Task 1, Step 5, after your canvas generator can create an SVG file.

# Project Architecture

Your A1 will begin with the directory hierarchy shown below.

```text
picture_this/
├── dune
├── dune-project
├── AUTHORS.md
├── lib/
│   ├── dune
│   ├── picture.ml
│   ├── parser.ml
│   ├── svg.ml
│   └── generator.ml
├── bin/
│   ├── dune
│   └── main.ml
├── test/
│   └── dune
└── examples/
    └── canvas.pic
```

The responsibilities of each file are:

- `lib/picture.ml` contains the typed representation of Picture This pictures.
- `lib/parser.ml` converts numbered source lines into typed picture data.
- `lib/svg.ml` converts typed picture data into SVG text.
- `lib/generator.ml` coordinates the workflow by reading `.pic` files, parsing, generating SVG, and writing `.svg` files.
- `bin/main.ml` handles command-line arguments, terminal communication, and exit status.

You are welcome to add additional files to your project as you wish. But do not eliminate any of these files, and do not move any of the existing files to a different directory.

## Dune Connections

Look at `lib/dune`. You will see:

```lisp
(library
 (name <whatever name you chose for your Dune project>))
```

That means the library built out of the source code in `lib/` is available to other code in the Dune project.

The library's name is the same as your Dune project name, which you chose when you created the project.

Next, look at `bin/dune`. You will see:

```lisp
(executable
 (name main)
 (libraries <whatever name you chose for your Dune project>))
```

That means the executable built from `bin/main.ml` is named `main.exe` and it links to the library built from `lib/`.

# What Belongs in `lib`

The library is the generator's back-end engine.

The library should own:

- the typed picture representation;
- color interpretation;
- line preparation and parsing;
- malformed-input errors;
- SVG rendering;
- cumulative-repeat calculations;
- file reading and writing;
- the file-to-file generation pipeline.

Library code should return values or explicit errors. It should not read command-line arguments, print terminal messages, or terminate the process.

The only file in the library that should perform file I/O is `generator.ml`.

The other library files should be a **pure functional core** - meaning they do not interact with the outside world. They should take typed values as input and return typed values or errors as output.

# What Belongs in `bin`

`bin/main.ml` should perform only the operations specific to running Picture This from a terminal:

1. Read the two command-line filenames.
2. Call the library's file generator.
3. On success, print nothing.
4. On failure, print the error and exit unsuccessfully.

Do not put picture traversal, SVG construction, parsing, or transformation logic in `bin/main.ml`.

# Code in `lib` vs. Code in `bin`

To help you understand the distinction between `lib` and `bin`, consider the following mental exercise.

Imagine that you are asked to implement a GUI version of Picture This in which the user selects input and output files using widgets.

The typed representation, parser, SVG renderer, error representation, and file I/O should not need to change. That code therefore belongs in `lib`.

Code that reads command-line arguments, communicates through the terminal, and selects a process exit status would change. So, that code belongs in `bin`.

# Testing with Cram

Cram tests describe a shell session. They run the real executable and compare its actual output with the output recorded in a `.t` test file.

For Picture This, that makes them ideal end-to-end tests:

```text
.pic source → executable → .svg output
```

## Your First Cram Test

Add the following stanza to `test/dune`:

```lisp
(cram (deps ../bin/main.exe (glob_files_rec ../examples/*)))
```

Then create `test/canvas.t`:

```text
Generate a canvas.
  $ dune exec ../bin/main.exe ../examples/canvas.pic canvas.svg
  $ cat canvas.svg
```

Run that test from the project root:

```text
dune test test/canvas.t
```

The first run fails because `test/canvas.t` does not yet contain expected SVG output.

Dune displays a corrected version of the `.t` file containing the output it observed. Inspect that SVG carefully.

If it is correct, accept it with:

```text
dune promote test/canvas.t
```

The test file will then contain the SVG output after the `cat` command. Future runs compare newly generated SVG against that expected output.

Be careful: promotion records the program's current behavior; it does not check that the behavior is correct.

It is your responsibility to ensure that the behavior is correct before promoting it. Review the corrected SVG and inspect the image in a browser before promoting it.

Cram runs each test in an isolated test directory.

The `deps` stanza makes `bin/main.exe` and the files in `examples/` available there. The paths in a Cram test are relative to that test directory, which is why the test uses `../bin/main.exe` and `../examples/canvas.pic`.

## Testing Errors

Cram can also check error outputs.

A command that exits unsuccessfully is followed by its exit status in square brackets:

```text
Report an invalid canvas.
  $ ../bin/main.exe ../examples/bad_canvas.pic bad_canvas.svg
  Error: Line 1: Width and height must be positive numbers
  [1]
```

The exact error wording is up to you, but it must be helpful and include line information for source errors.

You can use `dune promote` to accept corrected error output, just as you do for successful output. So you do not need to write the exact error message in advance. You can run the test, inspect the error, and then promote it.

## Writing Effective Cram Tests

Keep test files focused.

For example, you can have `test/canvas.t` check multiple correct canvas declarations and incorrect canvas declarations, but you can separate tests for more than just a canvas into separate test files.

Each test file should have a clear purpose and focus on a specific aspect of the language.

## Manual Browser Checks

Browser inspection catches visual mistakes that text comparison may not make obvious. It augments rather than replaces Cram tests.

At every checkpoint:

1. Run the complete executable on some `.pic` source files.
2. Open the generated `.svg` files in a browser.
3. Confirm that the visible results match the source order and intended geometry.
