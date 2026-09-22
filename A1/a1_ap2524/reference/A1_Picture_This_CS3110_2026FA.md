# A1: Picture This

## Overview

In this assignment, you will create Picture This, a small language for describing pictures. Your program will generate Scalable Vector Graphics (SVG) from a Picture This source file. You will begin with a language that describes only a blank canvas. Each task will add a few features while keeping the complete generator working.

By the end, your language will be able to produce posters, diagrams, and geometric art, such as this assignment's logo.

> **PICTURE THIS**  
> **A TINY GRAPHICS LANGUAGE**

## Learning Objectives

By the end of this assignment, you should be able to:

- Design algebraic data types to model hierarchical structures that represent a small graphics language.
- Convert input syntax into meaningful typed data with a recursive-descent parser, and back into output syntax with a recursive renderer.
- Organize a multi-file Dune project with library code and a thin command-line executable.
- Write Cram tests that verify end-to-end behavior.
- Continue to practice iterative development techniques.

## Important Updates Made to this Handout

None so far.

## A Glimpse of Picture This

You will build the generator gradually. For now, here is a glimpse of the complete core language and of the kind of picture it can produce. You do not need to understand or implement these forms yet; the tasks will introduce them one at a time.

This complete Picture This program is a small tour of the language:

```text
canvas 720 420 navy
rectangle 0 292 720 128 teal
transform translate 610 82
  transform scale 0.8
    circle 0 0 48 cream
    circle 18 -10 48 navy
  end
end
transform translate 58 292
  repeat 7 translate 88 0
    rectangle 0 -96 56 96 purple
    repeat 3 translate 16 0
      rectangle 8 -70 7 12 gold
    end
    circle 28 -110 9 red
  end
end
line 0 292 720 292 gold 4
text 360 370 24 cream Moon over Mini City
```

### Moon over Mini City

Picture This is line-oriented and case-sensitive. Each command header occupies one line. Keywords and color names are lowercase. Blank lines and leading and trailing whitespace are ignored.

The description of the language, below, uses a variant of [EBNF notation](https://en.wikipedia.org/wiki/Extended_Backus%E2%80%93Naur_form), with the following conventions:

- `::=` means "is defined as"
- `{ ... }` means "zero or more repetitions of ..."
- `|` means "or"
- `"<keyword>"` means a literal keyword

```text
picture        ::= canvas { element }
canvas         ::= "canvas" number number background EOL
background     ::= "none" | color
element        ::= circle | rectangle | line | text
                 | transform-block | repeat-block
circle         ::= "circle" number number number color EOL
rectangle      ::= "rectangle" number number number number color EOL
line            ::= "line" number number number number color number EOL
text            ::= "text" number number number color text-content EOL
transform-block ::= "transform" transformation EOL { element } "end" EOL
repeat-block   ::= "repeat" integer transformation EOL { element } "end" EOL
transformation ::= "translate" number number
                 | "rotate" number
                 | "scale" number
number         ::= a finite floating-point number
integer        ::= a nonnegative integer
color          ::= one of the 15 named colors, below
text-content   ::= one or more nonempty words separated by spaces
EOL            ::= the end of a nonblank input line
```

For a `number`, any syntax accepted by OCaml's `float_of_string_opt` is acceptable, provided the resulting value is finite. Thus values such as `nan`, `infinity`, and `-infinity` are not valid Picture This numbers. You can use `Float.is_finite` to perform this check.

## Named Colors

| Name | Hex code | Name | Hex code |
|---|---|---|---|
| black | `#111111` | white | `#ffffff` |
| gray | `#808080` | red | `#c1121f` |
| orange | `#f77f00` | yellow | `#fcbf49` |
| green | `#2a9d8f` | blue | `#277da1` |
| purple | `#7b2cbf` | pink | `#e76f91` |
| brown | `#8d6e63` | navy | `#091226` |
| teal | `#008080` | gold | `#d9a441` |
| cream | `#fff1b0` | | |

## Meet SVG

[SVG](https://en.wikipedia.org/wiki/Scalable_Vector_Graphics) (Scalable Vector Graphics) is a standard for describing two-dimensional graphics. It is widely supported by web browsers and other software.

Read the opening sections of the [SVG Quick Reference](https://canvas.cornell.edu/courses/90271/pages/a1-svg-quick-reference). Copy its complete two-shape SVG example into a temporary `.svg` file and open it in a browser. Experiment with changing a coordinate, radius, and/or color, then refresh the browser window to see your change. You will use only a small subset of SVG in this assignment, but it is helpful to understand the context.

### Debugging an SVG File

If an SVG is not producing the expected picture:

1. Make sure you are using a browser rather than VS Code; browsers often display helpful error messages that VS Code's image preview does not. In Chrome and Safari, scroll to the top of the browser window to see the error message and line number.
2. Check that the document begins with `<svg ...>` and ends with `</svg>`.
3. Check that every element either ends in `/>` or has a matching closing tag.
4. Check quotation marks around attributes.

---

# Task 0: Review the Policies

Before you begin programming, refresh yourself on the policies below.

## Implementation Restrictions

Do not use any imperative data structures in OCaml, including:

- References or the `ref` keyword
- Assignment with `:=`
- Records with the `mutable` keyword
- Arrays (with one narrow exception for command-line arguments, described below)

OCaml makes command-line arguments available in `Sys.argv`, which is an array. You will need to access that array to obtain command-line arguments. Otherwise, please do not use arrays.

Also do not use any libraries or tools for generating a parser or creating SVG. You will be building that functionality yourself as part of the assignment.

## Code Guidelines

Follow the A1 section of the [CS 3110 Programming Guidelines](https://canvas.cornell.edu/courses/90271/pages/cs-3110-programming-guidelines). In particular:

- Run `dune build` from the top-level project directory. It must finish without errors or warnings.
- Run `dune test` and keep the complete test suite passing.
- Format all `.ml` files with `ocamlformat`.
- Give every top-level function an OCamldoc specification in its `.ml` file.

## AI and Collaboration

The same policy as A0 applies here. We encourage collaboration with another student in the course, but only if you are both writing your own, separate solutions rather than one joint solution. You are permitted to use AI, but you must ensure that you learn the material and that your submission is your own work.

## Submission

Submit your work in Gradescope by `9:00:00 pm` on the due date. The grace period ends at `11:59:00 pm`; submissions during it incur no penalty. Submissions by email are not accepted.

Revisit [How to submit OCaml projects in Gradescope](https://canvas.cornell.edu/courses/90271/pages/how-to-submit-ocaml-projects-in-gradescope) for instructions.

---

# Task 1: Generate a Canvas

**Working program at the end of this task:** Given a source file containing one canvas declaration, the executable parses it, constructs a typed picture value, and generates a valid SVG document with the requested canvas dimensions and background.

You will build that generator in stages: set up the project, understand its architecture, read and number the input, interpret a canvas, generate SVG, then test the complete result. At every programming stage, run the program and observe what changed.

## Step 0: Create the Dune Project

Follow the [Dune project creation instructions](https://canvas.cornell.edu/courses/90271/pages/dune-project-creation) in Canvas. It creates `lib`, `bin`, and `test`.

Create these four empty files in `lib` now:

```text
picture.ml
parser.ml
svg.ml
generator.ml
```

Also create `examples/canvas.pic` (you will need to create the `examples` directory) containing:

```text
canvas 900 700 navy
```

Make sure that `dune build` succeeds.

## Step 1: Study the Architecture

Skim the first half of the [Architecture and Testing Guide](https://canvas.cornell.edu/courses/90271/pages/a1-architecture-and-testing-guide), stopping when you reach the section on Cram testing.

Open each of the five `.ml` files in `lib` and `bin`. At the top of each file, write an OCamldoc comment that describes the file's purpose based on your current understanding of the project architecture.

For example, `picture.ml` might say:

```ocaml
(** Typed representation of Picture This pictures. *)
```

## Step 2: Read and Number the Input

Work in `bin/main.ml` and `lib/generator.ml` to build the first runnable portion of the generator.

By the end of this step, your program will:

1. Accept the input and output filenames from the command line.
2. Read the input file through the library.
3. Attach line numbers to its contents.
4. Print those numbered lines to the terminal.

The program will not create the output file yet. You will add SVG generation and output in Step 4. For now, printing the numbered input gives you an observable way to confirm that the command-line interface, library, and file input are connected correctly.

### Accept the Two Filenames

Write code in `bin/main.ml` to accept exactly two positional command-line arguments: an input filename and an output filename.

Command-line arguments are available in the array `Sys.argv`. Access an array element with the syntax `array.(index)`. Element 0 is the program name, so the two filenames are available as `Sys.argv.(1)` and `Sys.argv.(2)`.

For the moment, print both filenames to the terminal. Then run:

```text
dune exec bin/main.exe -- examples/canvas.pic examples/canvas.svg
```

The `--` tells Dune that the arguments following it are for `bin/main.exe`, not for Dune itself.

If the user supplies the wrong number of arguments, print a helpful usage message and terminate unsuccessfully. Every program finishes with an exit status: status 0 means success, while a nonzero status means failure.

For example:

```ocaml
Printf.eprintf "Usage: %s <input.pic> <output.svg>\n" Sys.argv.(0);
exit 1
```

### Call the Library from the Executable

Next, connect `main.ml` to `generator.ml`. The eventual job of `generator.ml` is to coordinate the complete generation process: reading the input file, parsing it, rendering SVG, and writing the output file. In this step, implement only the first part of that process.

Write a function in `generator.ml` that accepts the input filename and returns its numbered lines. If the function is named `read_numbered_lines` and your Dune library is named `picture_this`, call it from `main.ml` by this full name:

```ocaml
Picture_this.Generator.read_numbered_lines input_filename
```

### VS Code Note

After adding a new library function or changing a function's type, run `dune build` so that VS Code can discover the change. If VS Code still shows stale information in `main.ml`, make and undo a trivial edit there to trigger another check.

### Read and Number the Lines

Inside the library function, read the input file as a list of lines:

```ocaml
In_channel.with_open_text input_filename In_channel.input_lines
```

This expression produces a `string list`: one string for each input line, without the trailing newline character.

Use `List.mapi` to pair each line with its one-based line number:

```ocaml
List.mapi (fun index line -> (index + 1, line)) lines
```

Return the numbered lines to `main.ml`. For the moment, have `main.ml` print them.

A one-line source file should produce output such as:

```text
1: canvas 900 700 navy
```

Here is an example of how to print a single numbered line:

```ocaml
Printf.printf "%d: %s\n" line_number line
```

To print every numbered line, you can use `List.iter`, which applies a function returning `unit` to every element of a list.

### Return Lines or an Error

Opening or reading a file can raise `Sys_error`. This exception contains the operating system's explanation of the failure. Catch it in `generator.ml` and return a helpful error to `main.ml` rather than allowing the exception to reach the user.

The standard-library result type represents either a successful value or an error:

```ocaml
type ('ok, 'error) result =
  | Ok of 'ok
  | Error of 'error
```

It resembles an option, but explicitly distinguishes success from failure.

Your function can return this type:

```ocaml
((int * string) list, string) result
```

A successful read produces `Ok numbered_lines`; a failed read produces `Error error_message`.

Plain strings are an acceptable error representation throughout this assignment. You are welcome to design a more structured error type, but you are not required to do so.

In `main.ml`, pattern match on that result:

- In the `Ok` case, print the numbered lines.
- In the `Error` case, print the message to the standard error channel and terminate unsuccessfully.

### Check the Complete Step

Before continuing, run the program with:

- the correct arguments;
- a missing argument;
- a nonexistent input filename;
- several different contents in the input file.

Confirm that valid input produces the expected numbered lines and that each failure produces a helpful message and a nonzero exit status.

## Step 3: Parse a Canvas Declaration

Build the first version of your parser in `lib/parser.ml`. Convert the numbered input lines from Step 2 into a typed value (defined in `lib/picture.ml`) that represents the canvas. Call your parsing function from `lib/generator.ml`.

For the moment, in `bin/main.ml` just report whether parsing succeeded or failed; and if it failed, report an error and line number as described below.

Begin by recognizing the canvas declaration.

The first nonblank line of every Picture This program has this form:

```text
canvas width height background
```

For example:

```text
canvas 900 700 navy
```

Or:

```text
canvas 600 400 none
```

We recommend transforming the input in small stages:

```text
[(1, ""); (2, " canvas 900 700 navy "); (3, "")]
        ↓ trim strings and ignore blank lines
[(2, "canvas 900 700 navy")]
        ↓ split remaining lines into words
[(2, ["canvas"; "900"; "700"; "navy"])]
        ↓ interpret the words
a typed canvas value
```

First, trim each line and discard the blank ones, but keep each remaining line paired with its original line number. That will let you report where a source error occurred. `String.trim` removes surrounding whitespace from a line.

Next, split the canvas line into words. `String.split_on_char ' '` splits at spaces, but repeated spaces produce empty strings, so filter those out. For this assignment, you may treat command words as separated by spaces; you do not need to treat tabs between words as separators. Do not flatten the entire file into one list of words. Picture This is line-oriented, and later commands will need those line boundaries.

Then use list pattern matching to recognize the required canvas declaration:

```text
["canvas"; width-text; height-text; background-text]
```

Any other shape is malformed for now.

Convert `width-text` and `height-text` with `float_of_string_opt`, which attempts to convert a numeric string without raising an exception. Geometric quantities are floating-point numbers, but the source may write either `20` or `20.0`; require both dimensions to be positive.

Interpret `background-text` as either `none` or one of the required colors.

Finally, construct a typed canvas value. Here is one reasonable starting representation you could put in `lib/picture.ml`:

```ocaml
type color =
  | Black
  | White
  | Gray
  | Red
  | Orange
  | Yellow
  | Green
  | Blue
  | Purple
  | Pink
  | Brown
  | Navy
  | Teal
  | Gold
  | Cream

type picture = {
  width : float;
  height : float;
  background : color option;
}
```

With this representation, the source word `none` becomes `None`, while `navy` becomes `Some Navy`. The strings representing the dimensions become float values.

You may use this representation as written, rename or reorganize it, or design another representation with the same strengths. You will extend - and may revise it - as later tasks add picture elements.

The process just described is the central type-design principle for A1: parse into meaning. Once parsing succeeds, later stages should work with typed information rather than repeatedly interpreting keywords and numeric parameters as strings. As you extend the language, also prefer representations in which nonsensical combinations are impossible (or at least difficult) to construct.

If any part of the input is malformed or its parameters are nonsensical, return an informative error instead of silently skipping, repairing, clamping, defaulting, or reinterpreting the input. Reporting the first error is sufficient; you do not need to recover and continue parsing.

Include the relevant source line number whenever there is one. If the file has no nonblank lines, report that fact without a line number. If a block reaches the end of the file without a matching `end`, report the line number of the block's opening `transform` or `repeat` command.

Use a new exception of your own design, named something like `ParseError`, to stop the internal parsing helpers at the first error. Those helpers may return ordinary successful values and raise the exception with a helpful message when parsing fails.

At the public boundary of `parser.ml`, catch that exception and convert it to an `Error` result; convert the successful parsed picture to `Ok`. Catch only your parser-specific exception so that unrelated programming errors remain visible. Code outside the parser should never need to handle the exception directly.

Run the program with each of the following inputs before continuing:

- A valid canvas declaration
- Blank lines and extra spaces around a valid declaration
- No canvas declaration
- An unknown color
- A nonnumeric or nonpositive dimension
- The wrong number of parameters in a canvas declaration

Confirm that `bin/main.ml` is successful on valid inputs and reports a helpful error on invalid inputs, including the relevant line number.

## Step 4: Render and Write the SVG

Write a function in `lib/svg.ml` to render the picture value into an SVG string. Then finish writing your generation function in `lib/generator.ml` by calling the SVG rendering function and writing its output to the specified file.

The output SVG file must contain an `<svg>` with the requested `width`, `height`, and `viewBox`. The `viewBox` should be set to `0 0 width height`.

For a named-color background, render a canvas-sized rectangle. For `none`, omit the background rectangle.

Finish parsing and rendering the complete input file before opening the output file. That way, invalid source does not create or overwrite an `.svg` file.

Then, in `generator.ml`, write the SVG text to the output filename with code like this:

```ocaml
Out_channel.with_open_text output_filename (fun channel ->
  output_string channel svg_text)
```

If the output file cannot be opened or written, have `generator.ml` return a helpful error. As before, `main.ml` prints the error and terminates unsuccessfully.

If the output file is successfully written, do not print any output to the terminal. That means you can now delete the printing of the numbered lines from `bin/main.ml`.

Run:

```text
dune exec bin/main.exe -- examples/canvas.pic examples/canvas.svg
```

Open `examples/canvas.svg` in a browser. Change the dimensions and background in `examples/canvas.pic`, rerun the command, and refresh the browser to confirm that the generated image changed.

The whitespace in the output SVG does not matter, so you do not need to format it. It is fine for the output to have extra spaces or newlines. The browser ignores them. Likewise, it is fine for floating-point numbers to have many decimal places. You do not need to round or format them, as long as they are valid numbers and equivalent to the input. For example, `width="900.000000"` is acceptable.

## Step 5: Test the Canvas Language

Now read the **Testing with Cram** sections of the [Architecture and Testing Guide](https://canvas.cornell.edu/courses/90271/pages/a1-architecture-and-testing-guide).

Add Cram tests that run the complete executable on a valid canvas source file, display the generated SVG, and check malformed or nonsensical canvas input.

Include a test for background `none` and a command-line error.

Inspect the corrected output before using `dune promote` to accept it.

## Checkpoint 1 of 6: A Working Canvas Generator

Run `dune build` and `dune test`.

Then:

- Generate at least one `.svg` file from a `.pic` file with a colored background.
- Generate at least one `.svg` file with background `none`.
- Open both SVG files in a browser.
- Introduce one malformed canvas line and confirm that the program reports an error instead of generating an SVG.

## Requirements for Task 1

- **Requirement 1.1: Project architecture.** The project must contain a generator-engine library, a thin executable linked against that library, Cram tests, and an examples directory.
- **Requirement 1.2: Command line.** The executable must accept input and output filenames as its two positional arguments.
- **Requirement 1.3: Canvas syntax.** The first nonblank source line must be parsed as the canvas declaration.
- **Requirement 1.4: Typed canvas.** Parsed dimensions and background must be represented as meaningful typed data rather than retained only as raw parameter strings.
- **Requirement 1.5: SVG document.** A valid source must cause the generator to produce a complete SVG document with the requested dimensions, view box, and background.
- **Requirement 1.6: Errors.** Malformed or nonsensical canvas input must produce a helpful error rather than a guessed or silently repaired canvas.
- **Requirement 1.7: Cram tests.** Cram tests must exercise a successful canvas generation and a malformed or nonsensical canvas input.

---

# Task 2: Add Filled Shapes

**Working program at the end of this task:** The generator accepts any ordered sequence of filled circles and rectangles after the canvas declaration and renders them in source order.

## Step 1: Extend the Representation

Add a representation for an ordered list of picture elements, which are either filled circles or filled rectangles.

Each element must store the information required to render it, including its position, size, and fill color. Review the EBNF for circles and rectangles above.

Apply the type-design principles introduced in Task 1. In particular, avoid representing a shape as a command-name string plus an unstructured list of parameter strings.

A successfully parsed circle, for example, should already have a center, radius, and fill color with useful OCaml types.

Ask:

- whether every value of your type has a sensible meaning;
- whether pattern matching identifies each case that must be handled;
- whether nonsensible combinations are impossible or at least difficult to construct.

## Step 2: Parse Circles and Rectangles

Filled shapes have these forms:

```text
circle center-x center-y radius color
rectangle x y width height color
```

For example:

```text
canvas 500 300 navy
circle 250 150 90 gold
rectangle 250 150 120 60 cream
```

A circle's coordinates locate its center. A rectangle's coordinates locate its upper-left corner. Radii, widths, and heights must be positive.

## Step 3: Render Shapes in Order

Translate each shape into the corresponding SVG element.

Preserve source order. For example, if a rectangle appears after a circle, the rectangle must appear later in the SVG and therefore cover the circle where they overlap.

## Step 4: Test the Extended Language

Add Cram tests.

Include:

- multiple sibling shapes to test order;
- decimal coordinates;
- unknown colors;
- nonsensical dimensions.

Inspect generated images to verify the correct rendering with your own eyes.

## Checkpoint 2 of 6: A Working Shape Generator

Generate a picture containing at least two overlapping circles and two overlapping rectangles.

Reverse two elements in the source and verify in the browser that the visible layering changes.

Confirm that all earlier canvas tests still pass.

## Requirements for Task 2

- **Requirement 2.1: Element representation.** The typed representation must distinguish circles from rectangles and store each form's required information meaningfully.
- **Requirement 2.2: Element lists.** A picture must contain an ordered list of zero or more elements.
- **Requirement 2.3: Circle syntax and rendering.** The generator must parse and render filled circles with the specified center, radius, and color.
- **Requirement 2.4: Rectangle syntax and rendering.** The generator must parse and render filled rectangles with the specified upper-left corner, dimensions, and color.
- **Requirement 2.5: Painting order.** Elements must be rendered in source order.
- **Requirement 2.6: Shape errors.** Malformed shapes, unknown colors, and nonsensical geometric parameters must produce helpful errors rather than guessed or repaired shapes.
- **Requirement 2.7: Cram tests.** Cram tests must exercise both forms, source order, errors, and complete source-to-SVG generation while preserving all Task 1 tests.

---

# Task 3: Add Lines and Text

**Working program at the end of this task:** The generator supports all four primitive elements and text containing spaces.

## Step 1: Complete the Primitive Elements

Lines have this form:

```text
line x1 y1 x2 y2 color width
```

For example:

```text
line 100 200 500 200 white 4
```

The two points are the endpoints. The final number is the positive stroke width.

Text has this form:

```text
text x y size color contents
```

For example:

```text
text 450 100 32 cream PICTURE THIS
```

The `y` coordinate describes the text baseline, not its top edge.

The contents are the nonempty words that remain on the line after the color. Picture This is whitespace-insensitive: discard extra spaces between those words and join them with single spaces in the rendered text.

Use `text-anchor="middle"` when rendering text to SVG.

You may assume that core-language input does not contain the XML-special characters `&`, `<`, or `>` in text content; you do not need to detect or reject them. Supporting those characters requires replacing them with XML escape sequences before inserting the text into SVG. You may implement that behavior as an optional extension, but it is not required.

## Step 2: Test Every Primitive

Add focused Cram tests for lines and text.

Include malformed line widths in error tests.

Add one complete source-to-SVG generation containing every primitive.

## Checkpoint 3 of 6: The Complete Primitive Language

Create and generate a small poster containing:

- filled shapes;
- a line;
- text.

Inspect the resulting SVG.

Confirm that every earlier test still passes.

## Requirements for Task 3

- **Requirement 3.1: Lines.** The generator must parse and render lines with two endpoints, a color, and a positive width.
- **Requirement 3.2: Text.** The generator must parse and render nonempty text with a position, positive size, and color.
- **Requirement 3.3: Errors.** Malformed or nonsensical line and text parameters must produce helpful errors.
- **Requirement 3.4: Cram tests.** Cram tests must exercise every primitive, text, relevant errors, and complete source-to-SVG generation.

---

# Task 4: Add Transformations

**Working program at the end of this task:** Picture This programs may translate, rotate, and uniformly scale blocks nested to any depth; the browser performs the geometric transformation from the generated SVG.

## Step 1: Study Recursive Descent Parsing

Read the [Recursive Descent Parsing Guide](https://canvas.cornell.edu/courses/90271/pages/a1-recursive-descent-parsing-guide).

Its filesystem language is not part of A1, but its central techniques apply here: parse a block until its `end`, return the parsed values and unconsumed input to the caller, and use an internal parser-specific exception to reach the public function that returns a result.

## Step 2: Represent Transformations and Their Bodies

Picture This has three transformation forms:

```text
translate dx dy
rotate degrees
scale factor
```

Translation and rotation parameters may be negative. A uniform scale factor must be positive.

Design a typed representation that distinguishes the three forms and stores exactly the information each requires.

A transformation applies to every element in its block:

```text
transform translate 450 350
  circle 0 0 100 gold
  transform rotate 45
    line 0 0 0 -200 cream 4
  end
end
```

Each transform block is an element that contains a transformation and an ordered list of elements. Because that body may contain further transform blocks, the element representation is recursive.

Each block header and each closing `end` occupies its own line. Indentation is encouraged for readability but has no meaning.

## Step 3: Parse Transform Blocks

When the parser encounters `transform`, parse its transformation and recursively parse its body until the matching `end`.

An `end` always closes the nearest open block.

Report an error for:

- an unexpected `end` at the top level;
- a transform block that reaches the end of the file without being closed.

You do not need to recover and continue after the error.

## Step 4: Render Transform Blocks

Preserve each transformation as a nested SVG `<g>` element with the corresponding `transform` attribute.

Do not compute new coordinates or implement rotation or scaling mathematics yourself; the browser applies the transformation.

Transformations operate relative to the current local origin. Nesting a rotation inside a translation is therefore the standard way to rotate around a chosen point.

Positive rotation appears clockwise in SVG because its vertical axis points downward.

## Step 5: Test Transformations

Add Cram tests for:

- each transformation by itself;
- empty transform blocks;
- sibling transform blocks;
- transform blocks nested several levels deep.

Verify:

- source order is preserved within and after each block;
- negative translations work;
- negative rotations work;
- positive fractional scaling works;
- unexpected and missing `end` commands are reported;
- malformed transformation headers are reported;
- nonsensical scale factors are reported.

Add a complete source-to-SVG test containing nesting.

## Checkpoint 4 of 6: Transformable Pictures

Generate a picture that:

- defines a small motif near `(0, 0)`;
- translates it to the canvas center;
- rotates or scales something inside it;
- includes transform blocks nested at least three levels deep.

Verify that source order is preserved within and after each block.

Confirm visually that changing only the outer translation moves the entire motif.

Remove one `end` and confirm that the error identifies the unclosed block rather than producing an SVG.

## Requirements for Task 4

- **Requirement 4.1: Recursive transformation representation.** Translation, rotation, and uniform scaling must have meaningful typed representations with the parameters each requires, and a transform block must contain an ordered list of elements, including nested transform blocks.
- **Requirement 4.2: Recursive-descent parsing.** The parser must recursively parse transform bodies and match each transform block with the appropriate `end`.
- **Requirement 4.3: Transform rendering.** The renderer must recursively preserve transformations and their children as nested SVG groups rather than calculating rewritten coordinates.
- **Requirement 4.4: Local origins.** Nested transformations must follow SVG's local-coordinate semantics.
- **Requirement 4.5: Order.** Transform blocks must preserve the source order of their children and later siblings.
- **Requirement 4.6: Transform and block errors.** Unexpected and missing `end` commands, malformed transformations, and nonsensical scale factors must produce helpful errors with relevant line information.
- **Requirement 4.7: Cram tests.** Cram tests must exercise each transformation, empty, sibling, and deeply nested transform blocks, source order, errors, and complete source-to-SVG generation while retaining every earlier test.

---

# Task 5: Add Cumulative Repetition

**Working program at the end of this task:** The complete core language can generate rows, grids, radial patterns, and nested geometric designs through transformed repetition.

## Step 1: Understand Repetition

A repeat block has this form:

```text
repeat count transformation
  elements
end
```

The count must be an integer. It produces `count` copies numbered from `0` through `count - 1`.

Copy `0` is untransformed. Copy `i` receives the cumulative transformation:

- `translate dx dy` becomes translation by `(i * dx, i * dy)`.
- `rotate degrees` becomes rotation by `i * degrees`.
- `scale factor` becomes scaling by `factor` raised to the power `i`.

A count of zero produces no copies. A count may not be negative.

For example:

```text
transform translate 450 350
  repeat 24 rotate 15
    line 0 -130 0 -290 gold 5
  end
end
```

The first line is unrotated, the second is rotated 15 degrees, and the last is rotated 345 degrees around the translated local origin.

Nested translated repetitions can create a grid:

```text
repeat 8 translate 60 0
  repeat 5 translate 0 60
    circle 30 30 18 teal
  end
end
```

## Step 2: Parse Repeat Blocks

The transformation syntax after `repeat count` is the same syntax used after `transform`.

A repeat body may contain any elements, including transformations and nested repetitions.

## Step 3: Render Copies in Order

Render copies in increasing copy-number order.

Each copy should become an SVG group with the appropriate cumulative transformation and recursively rendered body.

For example, this repetition:

```text
repeat 3 translate 10 5
  circle 20 20 4 teal
end
```

should render as three sibling `<g>` elements, one for each copy (shown here without surrounding document elements):

```xml
<g transform="translate(0 0)">
  <circle cx="20" cy="20" r="4" fill="#008080" />
</g>
<g transform="translate(10 5)">
  <circle cx="20" cy="20" r="4" fill="#008080" />
</g>
<g transform="translate(20 10)">
  <circle cx="20" cy="20" r="4" fill="#008080" />
</g>
```

The groups are siblings rather than nested inside one another. Each contains a rendered copy of the entire repeat body, and each transform is calculated from the original local coordinate system.

## Step 4: Test Repetition

Add Cram tests for zero, one, and several copies of each transformation form.

Verify:

- copy-zero semantics;
- cumulative parameters;
- copy order;
- nested repetition;
- malformed counts;
- negative counts.

Add at least one complete source-to-SVG repetition test.

## Checkpoint 5 of 6: The Complete Core Language

Generate one translated grid and one radial pattern.

Make a small change to count or transformation size and verify that the output changes predictably.

Confirm that all tests from Tasks 1-4 still pass.

## Requirements for Task 5

- **Requirement 5.1: Repeat representation.** A repeat value must contain its count, transformation, and recursively nested body.
- **Requirement 5.2: Repeat parsing.** The parser must parse repeat headers and recursively parse their bodies through the matching `end`.
- **Requirement 5.3: Cumulative semantics.** Copy `i` must receive the `i`th cumulative application of the specified transformation, with copy 0 untransformed.
- **Requirement 5.4: Copy order.** Copies must be rendered in increasing copy-number order.
- **Requirement 5.5: Repeat errors.** Malformed or negative repeat counts and malformed transformations must produce helpful errors.
- **Requirement 5.6: Cram tests.** Cram tests must exercise copy counts, every transformation form, nesting, errors, and complete source-to-SVG generation.

---

# Task 6: Create Your Picture

**Working program at the end of this task:** The generator is complete, tested, polished, and demonstrated by an original picture that uses the core language purposefully.

## Step 1: Create the Showcase

Create `examples/showcase.pic` and use your generator to generate `examples/showcase.svg`.

The picture may be:

- geometric art;
- a poster;
- a diagram;
- a constellation;
- a skyline;
- a chart;
- another idea of your choice.

Your showcase must visibly and purposefully use:

- all four primitive forms;
- filled circles and rectangles;
- translation, rotation, and scaling;
- at least one repeat;
- at least one recursively nested compound element.

Artistic skill is not part of the grade. The showcase is evidence that the complete language works and that you can use its features intentionally.

## Step 2: Polish the Generator Experience

Make command-line usage and errors easy to understand.

A successful run should be silent - that is, it should produce no output.

An unsuccessful run should explain the problem without an uncaught exception or a knowingly invalid SVG.

Review the complete project organization using the GUI thought experiment from Task 1.

Move into `lib` any code that would work unchanged if `main.ml` were replaced by a GUI.

Review all public library functions and their specifications.

## Step 3: Consider an Optional Extension

You may extend the language, but no extension is required for full credit.

Possibilities include:

- polygons;
- ellipses;
- opacity;
- hexadecimal or RGB colors;
- gradients;
- comments;
- another transformation.

If you implement an extension, give it:

- coherent source syntax;
- meaningful typed representation;
- parser and renderer support;
- error handling;
- tests;
- visible use in the showcase.

An extension does not compensate for a missing core requirement.

## Step 4: Review the Complete Requirements

Revisit every checkpoint above.

Later requirements add to earlier requirements; they do not replace them.

Run the entire test suite and regenerate the showcase from its source after your final code changes.

## Checkpoint 6 of 6: Picture This Complete

From a clean project state, run:

```text
dune build
dune test
```

Generate `examples/showcase.svg` from `examples/showcase.pic`.

Open it in a browser and confirm that every required showcase feature is visibly present.

Introduce one malformed input and confirm the generator still reports it appropriately.

Then regenerate the final SVG before submission.

## Final Requirements

- **Requirement 6.1: Showcase source.** The submission must contain an original `examples/showcase.pic` that uses every required showcase feature.
- **Requirement 6.2: Showcase output.** The submission must contain `examples/showcase.svg` freshly generated from that source by the submitted generator.
- **Requirement 6.3: Core completeness.** The final generator must satisfy every requirement from Tasks 1-5.
- **Requirement 6.4: Usability.** Successful command-line generation must be silent. Unsuccessful generation must report a helpful error and exit unsuccessfully.
- **Requirement 6.5: Architecture.** The typed representation, parser, SVG renderer, error handling, and reusable file-to-file generator must reside in `lib`; plain strings are an acceptable error representation. `bin/main.ml` must remain limited to command-line arguments, terminal communication, and exit status.
- **Requirement 6.6: OCaml restrictions.** The final generator must obey all restrictions stated in Task 0.
- **Requirement 6.7: Code guidelines.** The final project must build without errors or warnings, pass its tests, be formatted with `ocamlformat`, and provide appropriate OCamldoc specifications in `.ml` files.
- **Requirement 6.8: Optional extensions.** No extension is required for full credit. Any submitted extension must be coherent, tested, and compatible with the complete core language.

---

# Rubric

| Component | Criterion | Points |
|---|---|---:|
| Submitted program | Required parsing, rendering, error handling, and testing functionality | 25 |
| Submitted program | Functional representation, recursion, and library/executable architecture | 15 |
| Submitted program | Code quality and documentation | 5 |
| Submitted program | Generator usability and showcase | 5 |
| Technical interview | Arriving on time and ready to begin for the interview slot you booked | 25 |
| Technical interview | Explaining and justifying your code, demonstrating that you understand it, and answering questions about it | 15 |
| Technical interview | Making and explaining a requested change to your code during the interview | 10 |
| **Total** | | **100** |

# Technical Interview Question Bank

The same general instructions as A0 apply here.

1. **Reading Picture This.** Choose a nontrivial fragment of your showcase source. Explain the syntax and meaning of each command in that fragment, including the parameters, how any blocks are delimited, and which whitespace matters.
2. **Connecting Picture This to SVG.** Choose one primitive command in your Picture This source and find the SVG element it produces. Explain how each source parameter is represented in the SVG element and how the browser interprets its coordinates, dimensions, and color.
3. **Representing a picture.** Choose one form in your typed picture representation. What does each part mean, and what nonsensical combinations does your design make impossible or difficult to construct?
4. **Parsing into meaning.** Choose one valid source command. Trace how your parser converts its words into a typed value. Where are numeric text and keywords interpreted, and why do later stages not need to interpret them again?
5. **Handling errors.** Choose one malformed or nonsensical input tested by your submission. Trace how the error is detected, given useful context such as a line number, propagated to the executable, and reported to the user.
6. **Parsing a nested block.** Choose a nested transform or repeat block. Show how a recursive parser determines which elements belong to the block, recognizes its matching `end`, and returns any input that remains for the surrounding parse.
7. **Preserving source order.** Choose sibling elements whose order is visible in the generated SVG. Show how their order is preserved by both your parser and renderer, and explain what would change if that order were reversed.
8. **Rendering recursively.** Choose a compound element containing another compound element. Trace how your renderer turns it into nested SVG groups and reaches the primitive elements inside it.
9. **Applying transformations.** Choose a nested transformation from your showcase or tests. Explain which local coordinate system applies to an element inside it and why your renderer can preserve the transformation instead of calculating new coordinates itself.
10. **Computing repetition.** Show where a repeated copy's cumulative transformation is computed. For a copy number and transformation supplied by your TA, determine the resulting translation, rotation, or scale and explain why copy 0 is untransformed.
11. **Testing the complete pipeline.** Choose one Cram test that generates SVG. Explain what behavior it tests, what each relevant command and expected-output line means, and how the test would expose a plausible defect in your implementation.
12. **Organizing the project.** Suppose `bin/main.ml` were replaced by a graphical interface that let a user choose input and output files. Which parts of your submission could remain unchanged, which part would be replaced, and how does your module organization create that separation?

# Final Checklist

Before submitting, confirm each of the following:

- From the top-level project directory, `dune build` and `dune test` both finish successfully, and every `.ml` file is formatted with `ocamlformat`.
- I have reviewed every numbered requirement in Tasks 1-6 and confirmed that my final generator still satisfies it.
- My parser converts raw syntax into meaningful typed data; later stages do not repeatedly interpret command names or numeric parameters as strings.
- My representation distinguishes the forms of the language and makes nonsensical combinations difficult to construct.
- My generator reports malformed or nonsensical input instead of silently skipping, repairing, clamping, or defaulting it.
- My Cram tests cover successful generations, errors, nested structures, transformations, repetition, and small complete source-to-SVG generations.
- The typed representation, parser, SVG renderer, error representation, and file-to-file generator reside in `lib`; `bin/main.ml` contains only command-line and terminal glue.
- My implementation uses lists and recursive functions and none of the prohibited features or libraries.
- `examples/showcase.pic` purposefully uses every required core feature, and `examples/showcase.svg` was generated from it by my submitted generator.
- My project contains an `AUTHORS.md` file listing every collaborator, or stating that I worked alone.
- After uploading, I verified that Gradescope received the version I intend to submit.
