# A0: Pet Project

## Overview

In this assignment, you will create a text-based virtual pet simulator. The user will name the pet, care for it, encounter random events, and discover what the pet becomes. The user's decisions will change the pet's condition and determine its final form.

## Learning Objectives

By the end of this assignment, you should be able to:

- Create a Dune project.
- Write OCaml expressions using primitive types, operators, conditionals, and local definitions.
- Define OCaml functions that conform to given type signatures and behavioral specifications.
- Use state-passing style to represent changing state in a functional program.
- Use OCaml's printing, reading, and type-conversion functions to implement terminal interaction.
- Use OCaml's `Random` module to produce reproducible pseudorandom sequences of events.

Beyond transitioning to OCaml, the core functional-programming idea of this assignment is state-passing style: instead of mutable variables, you will use function parameters to represent the program's current state and recursive calls to continue with updated values. Each call to the main "loop" will receive the current state of the pet simulation, then pass the new values to the next call.

## Important Updates Made to this Handout

None so far.

# Task 0: Get Ready

## Development Process

This handout guides you through iterative development. You will first create a very small but working pet simulator. You will then add one group of features at a time, while keeping the program runnable throughout. **Do not wait until you have written the entire program to try running it.**

The numbered requirements are the authoritative specification for the assignment. Requirements from later tasks add to, rather than replace, earlier requirements.

Here is the development trajectory:

1. Build a pet that the user can name and feed once.
2. Extend it into a complete but deterministic simulation.
3. Add reproducible random events without changing the deterministic core rules.
4. Finish customizing the simulator to make it distinctively yours.

At every checkpoint, build and run your program before continuing. Fix compiler errors and obvious behavioral problems while the program is still small.

## Implementation Restrictions

To ensure that your solution is functional, not imperative, do not use:

- References or the `ref` keyword
- Assignment with `:=`
- Records with the `mutable` keyword
- `for` or `while` loops
- Arrays

## Code Guidelines

Follow the A0 section of the course [CS 3110 Programming Guidelines](https://canvas.cornell.edu/courses/90271/pages/cs-3110-programming-guidelines). In particular:

- Run `dune build` from the top-level project directory. It must finish without errors or warnings.
- Format `bin/main.ml` with `ocamlformat`.
- Give every top-level function in `bin/main.ml` an OCamldoc specification immediately above it. Each specification should describe what the function returns or what effect it performs in terms of its parameters, along with any precondition callers must satisfy. Describe behavior, not implementation. Local helper functions and ordinary local-value definitions do not require specifications.

## AI and Collaboration

You are permitted to use artificial intelligence (AI) on this assignment. You are responsible for the correctness of what you submit. You must be able to explain and justify every part of your submission, regardless of whether you or AI wrote it.

You may - and indeed are encouraged to - collaborate with a partner of your choice to discuss the requirements, brainstorm ideas, explain OCaml concepts, help diagnose bugs, and quiz one another. Each student must, however, design and write their own program and submit their own solution. Do not divide the implementation between students, jointly develop a single program, or copy or adapt another student's code.

Every submission must include a file named `AUTHORS.md`. List the names of everyone with whom you collaborated; if you worked alone, state that in the file. See the course [Academic Integrity policies](https://canvas.cornell.edu/courses/90271/pages/academic-integrity-policies) for more information.

## Submission

Your final submission is due in Gradescope by **9:00:00 pm on the due date**. We have a separate page on [how to submit OCaml projects in Gradescope](https://canvas.cornell.edu/courses/90271/pages/how-to-submit-ocaml-projects-in-gradescope). For consistency, all submissions must go through Gradescope. We cannot accept work by email. See the course [Assignment Submission policies](https://canvas.cornell.edu/courses/90271/pages/assignment-submission-policies) for more information.

To give you a little extra breathing room aka a grace period, Gradescope will stay open until **11:59:00 pm**. Submissions made during the grace period will be marked as "late," but don't worry - there is no grade penalty during the grace period. Submitting early will give you peace of mind. Remember: don't let the grace period turn into a stress period!

# Task 1: Build a One-Action Pet

> **Working program at the end of this task:** The user names a customized pet, sees its initial status, feeds it once, sees its updated status, and the program ends normally.

## Step 0: Create the Dune Project

Follow the Dune project creation instructions ([Canvas](https://canvas.cornell.edu/courses/90271/pages/dune-project-creation)) to create a new Dune project for this assignment. All your work for this warmup assignment will be in `bin/main.ml`. Later assignments will, of course, use more files.

## Step 1: Design the Pet and Opening

Choose the kind of pet your program raises. It may be an ordinary animal, a fantastical creature, an unusual object, or something entirely of your own invention. For example, your pet might be a capybara, moon dragon, sentient toaster, baby kraken, or anxious cactus.

Make the program print a title and an opening message. As part of those, let the user know what kind of pet they are raising. Ask the user to give the pet a name and use that name in later output.

## Step 2: Display the Initial State

Your pet has three integer attributes:

- Fullness
- Happiness
- Energy

Each attribute begins at **50** and must always remain between **0 and 100**, inclusive. Display the pet's name and all three initial attributes.

## Step 3: Feed the Pet Once

For this first iteration, do not ask the user to choose an action. Instead, automatically feed the pet once. Feeding has these effects:

- Fullness increases by 25.
- Happiness increases by 5.
- Energy decreases by 5.

Print a customized description of what happens when the pet is fed.

## Step 4: Finish the First Version

Display the updated state, print a closing message, and allow the program to terminate normally.

### Checkpoint 1 of 4: A Working One-Action Pet

Build and run your program now. Starting from 50 in every attribute, feeding once should produce:

- Fullness: **75**
- Happiness: **55**
- Energy: **45**

Do not continue until this small program works from beginning to end.

## Requirements for Task 1

- **Requirement 1.1: Terminal interaction.** The program must run in the terminal, read the user's input from standard input, and print its output to standard output.
- **Requirement 1.2: Pet name.** The program must ask the user to name the pet and use that name in its output.
- **Requirement 1.3: Customization.** The kind of pet, opening message, feeding message, and closing message must be chosen by you.
- **Requirement 1.4: Initial state.** Fullness, happiness, and energy must each begin at 50.
- **Requirement 1.5: Feeding effects.** Feeding must change the attributes by exactly +25 fullness, +5 happiness, and -5 energy.
- **Requirement 1.6: Complete interaction.** The program must provide an opening, naming, initial status, one feeding action (for Task 1 only - in Task 2 this will be generalized), updated status, closing, and normal termination.

# Task 2: Build the Deterministic Care Loop

> **Working program at the end of this task:** The simulation goes through a five-turn day with care actions, status checks, invalid-input handling, an option to end early, and a final transformation. The simulation is fully playable but does not yet include random events.

## Step 1: Compute Wellness and Mood

The pet's **wellness score** is the integer average of its three attributes.

The pet's **mood** is determined by the following rules, applied in the order shown:

1. If fullness is at most 20, the mood is **hungry**.
2. Otherwise, if energy is at most 20, the mood is **sleepy**.
3. Otherwise, if happiness is at most 20, the mood is **lonely**.
4. Otherwise, if wellness is at least 75, the mood is **delighted**.
5. Otherwise, the mood is **content**.

Augment the pet's status report to display the pet's name, all three attributes, its wellness score, and its current mood. Add a narrative description of what the pet is doing customized to its mood.

## Step 2: Add the Complete Menu of Actions

Implement the simulation as a recursive function:

```ocaml
(** [main_loop name turn fullness happiness energy] runs the virtual-pet
    simulation beginning on turn [turn], with the pet named [name] having
    the given attribute values. *)
let rec main_loop name turn fullness happiness energy = ...
```

The parameters of `main_loop` represent the complete changing state of the simulation. The simulation begins on **turn 1**.

On each turn, offer the user these choices:

1. Feed the pet.
2. Play with the pet.
3. Let the pet nap.
4. Perform a special activity designed for your pet.
5. Check on the pet.
6. End the day early.

If the user enters an invalid menu choice, print a helpful message and offer the same turn again by recursively calling `main_loop` with all five arguments unchanged.

### Care Action Effects

The first four choices are care actions. Their effects are:

| Action | Fullness | Happiness | Energy |
|---|---:|---:|---:|
| Feed | +25 | +5 | -5 |
| Play | -10 | +20 | -15 |
| Nap | -10 | -5 | +25 |
| Special activity | -15 | +30 | -25 |

When computing new attributes, make sure that each attribute always stays clamped between **0 and 100**, inclusive. After a valid care action, recursively call `main_loop` with the turn increased by 1 and all three new, clamped attributes.

Choose and name the special activity yourself. It should be tailored to your pet type. A dragon might practice breathing fire, while a toaster might toast an especially exciting CTB bagel. The numerical effects must be exactly as shown above.

The fifth choice, checking on the pet, displays the pet's status without changing any attributes. Checking status must not advance the turn. After a status check, recursively call `main_loop` with all five arguments unchanged.

The final choice, end the day early, brings the simulation to an end before the full five turns have occurred. The simulation then proceeds immediately to the final status report.

## Step 3: Show the Outcome

When the user ends the day or completes five care actions, print a final report containing the pet's final attributes, wellness, and mood. Then select one of these outcomes, applying the rules in the order shown:

1. If any attribute is 0, the pet needs **immediate TLC** (tender loving care).
2. Otherwise, if wellness is at least 75, the pet is **thriving**.
3. Otherwise, if wellness is at least 55, the pet is **doing well**.
4. Otherwise, if wellness is at least 35, the pet is **frazzled**.
5. Otherwise, the pet is **neglected**.

For each outcome, invent a form that your particular pet becomes and narrate the transformation. A thriving moon dragon might become a radiant comet dragon; a frazzled toaster might start smoking and set off a fire alarm. The form should reflect both the outcome and the pet type. The narration must include the words **"immediate TLC," "thriving," "doing well," "frazzled," or "neglected,"** based on the outcome.

A disappointing outcome may be humorous or gently reproachful, but please keep this G-rated: don't allow any pets to suffer permanent harm.

### Checkpoint 2 of 4: A Complete Deterministic Simulation

Build and run the complete deterministic simulation. Try all four care actions. Check status more than once during the same turn. Enter an invalid choice and verify that nothing changes. Complete five care actions in one run and end early in another. Both runs should reach an appropriate final outcome.

## Requirements for Task 2

- **Requirement 2.1: Complete menu.** Every turn must offer all six choices listed above.
- **Requirement 2.2: Action effects.** Feed, play, nap, and the special activity must have exactly the numerical effects shown in the care-actions table.
- **Requirement 2.3: Care-action behavior.** Each care action must print a short description, apply its effects, clamp every updated attribute to be in bounds, advance the turn by 1, and continue the simulation.
- **Requirement 2.4: Status command.** The status command must display the pet's name, fullness, happiness, energy, wellness, and mood without changing the state or advancing the turn.
- **Requirement 2.5: Invalid commands.** An invalid command must print a helpful message, must not change the state or advance the turn, and must give the user a chance to choose again.
- **Requirement 2.6: Ending early.** The end-day command must bring the simulation to a close and print the final report.
- **Requirement 2.7: Five care actions.** Unless the user ends early, the simulation must end after exactly five care actions. Status checks and invalid commands do not count as care actions.
- **Requirement 2.8: Final report.** The final report must show the final attributes, wellness, and mood, then display the outcome by applying the rules in the stated order.
- **Requirement 2.9: Final forms.** You must invent and narrate a distinct final form of the pet for each outcome.

# Task 3: Add Reproducible Random Events

> **Working program at the end of this task:** The complete simulation now includes random events, but a lucky number makes the same playthrough reproducible. The deterministic care-action rules and final-outcome rules remain unchanged.

## Step 1: Ask for a Lucky Number

When the program begins, ask the user for an integer to use as the pet's lucky number. Use that number to initialize OCaml's random-number generator exactly once with this function application:

```ocaml
Random.init lucky_number
```

You must call `Random.init` only once in the entire program, and that must happen before you generate any random numbers.

To ensure that the user's input is an integer, you will need to use exception handling. We will cover that in detail later. For now, you can adapt this code snippet:

```ocaml
(** [get_lucky_number ()] prompts the user for an integer and returns it. If
    the user enters a non-integer, the function prints a message and prompts
    again. *)
let rec get_lucky_number () =
  try int_of_string (read_line ()) with
  | Failure _ ->
      print_endline "Please enter a valid integer.";
      get_lucky_number ()
```

## Step 2: Implement the Event Rules

After each valid care action, generate exactly one event with this expression:

```ocaml
Random.int 5
```

The result is an integer from **0 through 4**. Its effects are:

| Code | Event kind | Fullness | Happiness | Energy |
|---:|---|---:|---:|---:|
| 0 | Nothing unusual | 0 | 0 | 0 |
| 1 | Finds a snack | +10 | 0 | 0 |
| 2 | Gets the zoomies | 0 | +15 | -10 |
| 3 | Takes an unexpected nap | -5 | 0 | +15 |
| 4 | Experiences a minor mishap | 0 | -10 | 0 |

Invent your own narration for all five events. The narration should fit your pet and should incorporate its name where appropriate. The numerical effects must be exactly those in the table.

For each valid care action:

1. Print the customized care-action description and apply its numeric effects, including clamping.
2. Generate and narrate exactly one random event and apply its numeric effects, including clamping.
3. Continue to the next turn.

Do not generate an event for a status check, an invalid command, or the command to end the day.

## Step 3: Check Reproducibility

A lucky number makes the random behavior reproducible. Two runs that use the same lucky number and the same complete sequence of commands must produce the same events and the same final state.

### Checkpoint 3 of 4: A Reproducible Random Simulation

Run a reproducibility experiment. Record a lucky number and a complete command sequence. Run the program twice with exactly those inputs and verify that the events, attributes, and final form match. Then insert extra status checks and invalid commands; they must not change which events occur later.

## Requirements for Task 3

- **Requirement 3.1: Lucky number.** The program must ask for an integer lucky number and call `Random.init` with it exactly once.
- **Requirement 3.2: Event timing.** The program must generate a random event after each care action.
- **Requirement 3.3: Event effects.** The event must have exactly the numerical effects shown in the random-events table.
- **Requirement 3.4: Event narration.** Every event must have narration customized to the kind of pet.
- **Requirement 3.5: Order of effects.** The program must perform the care action, clamp, perform the event, and clamp again.
- **Requirement 3.6: Non-care commands.** Status checks, invalid commands, and ending the day must not generate or consume a random event.
- **Requirement 3.7: Reproducibility.** The same lucky number and command sequence must produce the same random events and final state.

# Task 4: Finish Your Distinctive Pet

> **Working program at the end of this task:** The required simulation is complete, polished, easy to use, and recognizably your own.

## Step 1: Complete the Customization

Double-check that you have customized all of the following:

- The program's title and opening
- The special activity
- The descriptions of all four care actions
- The narration of all five random events
- The pet's reactions and status messages
- The form associated with each final outcome

## Step 2: Polish the User Experience

Make the program pleasant and easy to use. Clearly number all choices, explain what input is expected, identify the current turn, and format status reports so they are easy to read. You may add cosmetic features, but do not change the required numerical rules.

## Step 3: Review the Complete Requirements

Revisit every checkpoint above. Later requirements add to earlier requirements; they do not replace them. Make sure the final program still satisfies every requirement from Tasks 1, 2, and 3.

### Checkpoint 4 of 4: Required Program Complete

Perform a final manual review. Start from a fresh run and deliberately exercise every menu choice and outcome you reasonably can. Confirm that the program is still runnable after your final edits and that every customized feature is visible to the user without reading the source code.

## Final Requirements

- **Requirement 4.1: Customization.** The submission must customize every item in the list above and must be recognizably the student's own work.
- **Requirement 4.2: Interface.** The interface must clearly communicate the available choices, expected input, current turn, status, events, and final outcome.
- **Requirement 4.3: Cosmetic additions.** Cosmetic additions must not change any required numerical effects, turn rules, event rules, mood rules, or final-outcome rules.
- **Requirement 4.4: Complete specification.** The final program must satisfy all requirements from every earlier checkpoint.
- **Requirement 4.5: OCaml restrictions.** The final program must obey all OCaml restrictions stated near the beginning of this handout.
- **Requirement 4.6: Code guidelines.** The final program must follow the A0 section of the CS 3110 Programming Guidelines. In particular, `dune build` must finish without errors or warnings, `bin/main.ml` must be formatted with `ocamlformat`, and every top-level function must have an OCamldoc specification that follows the rules in Task 0.

# Rubric

| Component | Criterion | Points |
|---|---|---:|
| Submitted program | Required functionality | 25 |
| Submitted program | Functional-programming implementation | 15 |
| Submitted program | Code quality and documentation | 5 |
| Submitted program | User experience and polish | 5 |
| Technical interview | Arriving on time and ready to begin for the interview slot you booked | 25 |
| Technical interview | Explaining and justifying your code, demonstrating that you understand it, and answering questions about it | 15 |
| Technical interview | Making and explaining a requested change to your code during the interview | 10 |
| **Total** |  | **100** |

# Technical Interview Logistics

You will book an appointment with a TA/CA to discuss your submission. The interview will last **10 minutes**. We will post details about how to book appointments sometime around **Tue Sept 15 or Wed Sept 16**; we're still putting together a schedule.

The interview will be conducted in person. You need to bring your laptop to the interview and have your code open in VS Code and ready to discuss. You may not use any outside resources during the interview, including notes, websites, or AI tools.

During the interview, you will be asked one of the questions below (from the question bank), then you will be asked to make a small modification to your code (from a bank of possible modifications which we are not publishing in advance).

# Technical Interview Question Bank

Your interviewer will choose one primary question at random from this bank. We are interested in whether you can explain how your program works, not whether you can recite wording from lecture or the textbook. When a question asks you to discuss a function, action, or execution path, you may choose which example from your program to use. Your TA may provide small concrete input values for you to trace.

The strongest answers will be clear, correct, and self-directed. Partial credit is available for answers that demonstrate some understanding but contain gaps or require prompting or hints.

1. **Starting the program.** Show where execution of your program begins. How does control reach the first call to `main_loop`?
2. **Understanding a function.** Choose one function you defined. Explain its inputs, result, and type.
3. **Input, output, and `unit`.** Show a terminal I/O expression in your program that has type `unit`. What effect does it perform, and how is it sequenced with what the program does next?
4. **Representing state.** Show the parameters that represent the changing pet state. What does each parameter mean?
5. **Creating the next state.** Choose one care action and one attribute. Show where your program supplies that attribute's updated value to the next call to `main_loop`. Why does this create a new state rather than change the current one?
6. **Preserving state.** Choose either a status check or an invalid command. Show why it leaves both the pet's attributes and the turn unchanged.
7. **Ending the recursion.** Choose either completing five care actions or ending the day early. Show where and why that execution path terminates instead of making another recursive call.
8. **Clamping attributes.** Show where your program clamps attribute values. Using values supplied by your TA, explain why clamping after the action and again after the event can affect the result.
9. **Applying ordered rules.** Choose either mood or final outcome. Using attribute values provided by your TA, determine the result and explain how the order of the conditions matters.
10. **Initializing randomness.** Show where `Random.init` is called. What does the lucky number guarantee when two runs receive the same sequence of commands?
11. **Generating random events.** Show where `Random.int` is called. Why don't status checks, invalid commands, and ending the day change the sequence of care-action events?
12. **Organizing the code.** Choose one helper function or local definition. What computation does it represent, and how does separating that computation make the program easier to understand?

# Final Checklist

Before submitting, confirm each of the following:

- From the top-level project directory, `dune build` finishes without errors or warnings; `bin/main.ml` is formatted with `ocamlformat`; and every top-level function has an OCamldoc specification.
- I have reviewed every numbered requirement in Tasks 1-4 and confirmed that my final program still satisfies it.
- I have completed a full playthrough that exercises all four care actions, a status check, invalid input, and the final transformation.
- I have tested both completing five care actions and ending the day early, and I have checked that attributes always remain between 0 and 100.
- I have repeated a playthrough with the same lucky number and commands and confirmed that it produces the same random events and final state.
- My program represents its changing state through parameters to the recursive loop and uses none of the prohibited features.
- My interface clearly communicates the expected input, available actions, current turn, pet status, random events, and final outcome.
- My project contains an `AUTHORS.md` file listing every collaborator, or stating that I worked alone.
- After uploading, I verified that Gradescope received the version I intend to submit.

---

*Converted from the supplied A0: Pet Project handout for convenient viewing in VS Code. The assignment requirements above are based on the provided PDF.*
