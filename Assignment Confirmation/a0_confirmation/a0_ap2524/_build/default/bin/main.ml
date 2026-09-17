(* Debug checkpoints for testing controls. *)
type checkpointDebug =
  | C1
  | C2
  | C3
  | C4

let stringOfCheckpoint = function
  | C1 -> "C1"
  | C2 -> "C2"
  | C3 -> "C3"
  | C4 -> "C4"

(* DEBUG on off. *)
let debug = false

(* Normal mode is C4. *)
let checkpointMode = C4

(* Testing switches for the four checkpoints. *)
let testingC1 = checkpointMode = C1
let testingC2 = checkpointMode = C2
let testingC3 = checkpointMode = C3
let testingC4 = checkpointMode = C4
let eventsOn = testingC3 || testingC4

type petType = {
  name : string;
  fullness : int;
  happiness : int;
  energy : int;
}

(* -- ACTIONS -- *)
type actionType =
  | PetAction of (int * int * int) * string (*changes, display text*)
  | RandAction of
      int * (int * int * int) * string (*index, changes, display text*)
  | StaticAction of string

type mood =
  | Hungry
  | Sleepy
  | Lonely
  | Delighted
  | Content

type outcome =
  | NeedsTLC
  | Thriving
  | DoingWell
  | Frazzled
  | Neglected

type command =
  | Care of actionType
  | Check of actionType
  | EndDay of actionType

(* DEBUG: print a message while testing. *)
let debugPrint message = if debug then Printf.printf "[DEBUG] %s\n" message
let clamp value = min (max value 0) 100
let makeDefaultPet name = { name; fullness = 50; happiness = 50; energy = 50 }
let getWellness pet = (pet.fullness + pet.happiness + pet.energy) / 3

(* Normal care *)
let feedAction = PetAction ((25, 5, -5), "Feed")
let playAction = PetAction ((-10, 20, -15), "Play")
let napAction = PetAction ((-10, -5, 25), "Nap")
let specialAction = PetAction ((-15, 30, -25), "Catnip Chase")

(* Random actions. *)
let nothingAction = RandAction (0, (0, 0, 0), "Nothing unusual")
let findSnackAction = RandAction (1, (10, 0, 0), "Found a snack")
let zoomiesAction = RandAction (2, (0, 15, -10), "Got the zoomies")
let unexpectedNapAction = RandAction (3, (-5, 0, 15), "Unexpected nap")
let mishapAction = RandAction (4, (0, -10, 0), "Minor mishap")

(* Static actions. *)
let checkAction = StaticAction "Check on your pet"
let skipAction = StaticAction "End the day early"

let getActionName = function
  | PetAction (_, text) -> text
  | RandAction (_, _, text) -> text
  | StaticAction text -> text

let getActionDescription pet = function
  | PetAction (_, "Feed") -> Strings.actionDescription pet.name "Feed"
  | PetAction (_, "Play") -> Strings.actionDescription pet.name "Play"
  | PetAction (_, "Nap") -> Strings.actionDescription pet.name "Nap"
  | PetAction (_, "Catnip Chase") ->
      Strings.actionDescription pet.name "Special"
  | PetAction (_, _) -> failwith "Invalid action"
  | RandAction (_, _, text) -> text
  | StaticAction text -> text

(* -- MOOD AND OUTCOME -- *)
let stringOfMood = function
  | Hungry -> "Hungry"
  | Sleepy -> "Sleepy"
  | Lonely -> "Lonely"
  | Delighted -> "Delighted"
  | Content -> "Content"

let moodDescription pet = function
  | Hungry -> Strings.moodDescription pet.name "Hungry"
  | Sleepy -> Strings.moodDescription pet.name "Sleepy"
  | Lonely -> Strings.moodDescription pet.name "Lonely"
  | Delighted -> Strings.moodDescription pet.name "Delighted"
  | Content -> Strings.moodDescription pet.name "Content"

let getMood pet =
  if pet.fullness <= 20 then Hungry
  else if pet.energy <= 20 then Sleepy
  else if pet.happiness <= 20 then Lonely
  else if getWellness pet >= 75 then Delighted
  else Content

let stringOfOutcome = function
  | NeedsTLC -> "Immediate TLC"
  | Thriving -> "Thriving"
  | DoingWell -> "Doing well"
  | Frazzled -> "Frazzled"
  | Neglected -> "Neglected"

let getOutcome pet =
  let wellness = getWellness pet in
  if pet.fullness = 0 || pet.happiness = 0 || pet.energy = 0 then NeedsTLC
  else if wellness >= 75 then Thriving
  else if wellness >= 55 then DoingWell
  else if wellness >= 35 then Frazzled
  else Neglected

(** Returns a pet with updated attributes. *)
let calcUpdatedPet pet dFullness dHappiness dEnergy =
  {
    name = pet.name;
    fullness = clamp (pet.fullness + dFullness);
    happiness = clamp (pet.happiness + dHappiness);
    energy = clamp (pet.energy + dEnergy);
  }

(** Applies an action to a pet. *)
let applyAction pet action =
  let dFullness, dHappiness, dEnergy =
    match action with
    | PetAction (deltas, _) -> deltas
    | RandAction (_, deltas, _) -> deltas
    | StaticAction _ -> (0, 0, 0)
  in
  calcUpdatedPet pet dFullness dHappiness dEnergy

(* Custom text for random actions. *)
let eventDescription pet = function
  | RandAction (_, _, "Nothing unusual") ->
      Strings.eventDescription pet.name "NothingUnusual"
  | RandAction (_, _, "Found a snack") ->
      Strings.eventDescription pet.name "FoundSnack"
  | RandAction (_, _, "Got the zoomies") ->
      Strings.eventDescription pet.name "Zoomies"
  | RandAction (_, _, "Unexpected nap") ->
      Strings.eventDescription pet.name "UnexpectedNap"
  | RandAction (_, _, "Minor mishap") ->
      Strings.eventDescription pet.name "MinorMishap"
  | _ -> ""

let menuText turn = Strings.menuText turn

let rec getPetName () =
  Printf.printf "%s" Strings.namePrompt;
  match String.trim (read_line ()) with
  | "" ->
      print_endline Strings.emptyName;
      getPetName ()
  | name -> name

let rec getLuckyNumber () =
  Printf.printf "%s" Strings.luckyNumberPrompt;
  try int_of_string (String.trim (read_line ()))
  with Failure _ ->
    print_endline Strings.invalidLuckyNumber;
    getLuckyNumber ()

(** Reads a menu choice from 1 through 6. *)
let getMenuChoice () =
  try
    let choice = int_of_string (String.trim (read_line ())) in
    if choice >= 1 && choice <= 6 then Some choice else None
  with Failure _ -> None

let printStatus pet =
  let wellness = getWellness pet in
  let mood = getMood pet in
  print_endline "----------------------------------------";
  Printf.printf "Pet: %s\n" pet.name;
  Printf.printf "Fullness:  %d / 100\n" pet.fullness;
  Printf.printf "Happiness: %d / 100\n" pet.happiness;
  Printf.printf "Energy:    %d / 100\n" pet.energy;
  Printf.printf "Wellness:  %d / 100\n" wellness;
  Printf.printf "Mood:      %s\n" (stringOfMood mood);
  print_endline (Strings.catForMood (stringOfMood mood));
  Printf.printf "%s\n" (moodDescription pet mood);
  print_endline "----------------------------------------"

let printWelcome () =
  if debug then
    Printf.printf "[DEBUG] DEBUG IS ENABLED. \n CURRENT CHECKPOINT: %s\n"
      (stringOfCheckpoint checkpointMode);
  if not (checkpointMode = C4) then
    Printf.printf
      "[DEBUG] Working in non-default checkpoint level of %s. Random events \
       are %s.\n"
      (stringOfCheckpoint checkpointMode)
      (if eventsOn then "ON" else "OFF");
  print_endline Strings.welcome;
  print_endline Strings.cat

(** Returns the final form and story. *)
let finalFormAndStory pet = function
  | NeedsTLC -> Strings.finalFormAndStory pet.name "NeedsTlc"
  | Thriving -> Strings.finalFormAndStory pet.name "Thriving"
  | DoingWell -> Strings.finalFormAndStory pet.name "DoingWell"
  | Frazzled -> Strings.finalFormAndStory pet.name "Frazzled"
  | Neglected -> Strings.finalFormAndStory pet.name "Neglected"

let printFinalReport pet =
  let outcome = getOutcome pet in
  let finalForm, story = finalFormAndStory pet outcome in
  print_endline "\n========================================";
  print_endline "              FINAL REPORT              ";
  print_endline "========================================";
  printStatus pet;
  Printf.printf "Outcome: %s\n" (stringOfOutcome outcome);
  Printf.printf "Final form: %s\n" finalForm;
  print_endline story;
  print_endline Strings.closing;
  debugPrint
    (Printf.sprintf "Final outcome selected: %s" (stringOfOutcome outcome))

(** Ends the simulation. *)
let endDay pet =
  print_endline "\nThe day has ended.";
  printFinalReport pet

(** Prints the care action. *)
let printActionDescription pet action =
  Printf.printf "\n %s\n" (getActionDescription pet action);
  print_endline
    (Strings.catForAction
       (match action with
       | PetAction (_, "Feed") -> "Feed"
       | PetAction (_, "Play") -> "Play"
       | PetAction (_, "Nap") -> "Nap"
       | _ -> "Special"));
  debugPrint
    (Printf.sprintf "Care action: %s | before = (%d, %d, %d)"
       (getActionName action) pet.fullness pet.happiness pet.energy)

(** Applies care and one event. *)
let performCareAction pet action =
  printActionDescription pet action;
  let afterAction = applyAction pet action in
  debugPrint
    (Printf.sprintf "after care = (%d, %d, %d)" afterAction.fullness
       afterAction.happiness afterAction.energy);
  if not eventsOn then afterAction
  else
    let code = Random.int 5 in
    let event =
      match code with
      | 0 -> nothingAction
      | 1 -> findSnackAction
      | 2 -> zoomiesAction
      | 3 -> unexpectedNapAction
      | 4 -> mishapAction
      | _ -> failwith "How did we get here?"
    in
    let afterEvent = applyAction afterAction event in
    if debug then Printf.printf "   Random event: %s\n" (getActionName event);
    print_string "Along the way, ";
    Printf.printf "%s\n" (eventDescription pet event);
    debugPrint
      (Printf.sprintf "Random code: %d | event = %s | after care = (%d, %d, %d)"
         code (getActionName event) afterAction.fullness afterAction.happiness
         afterAction.energy);
    afterEvent

(** Returns the command for a menu choice. *)
let commandOfChoice = function
  | 1 -> Care feedAction
  | 2 -> Care playAction
  | 3 -> Care napAction
  | 4 -> Care specialAction
  | 5 -> Check checkAction
  | 6 -> EndDay skipAction
  | _ -> invalid_arg "command_of_choice: choice must be between 1 and 6"

(** Runs the simulation one turn at a time. *)
let rec main_loop name turn fullness happiness energy =
  (* if not debug then ignore (Sys.command "clear"); Clear Terminal *)
  if turn > 5 then endDay { name; fullness; happiness; energy }
  else
    let pet = { name; fullness; happiness; energy } in
    Printf.printf "%s" (menuText turn);
    match getMenuChoice () with
    | None ->
        print_endline Strings.invalidChoice;
        debugPrint
          (Printf.sprintf "Invalid input: state unchanged; turn remains %d."
             turn);
        main_loop name turn fullness happiness energy
    | Some choice -> (
        let command = commandOfChoice choice in
        match command with
        | Check _ ->
            printStatus pet;
            debugPrint
              (Printf.sprintf "Status check: state unchanged; turn remains %d."
                 turn);
            main_loop name turn fullness happiness energy
        | EndDay _ ->
            debugPrint (Printf.sprintf "Ending early on turn %d." turn);
            endDay pet
        | Care action ->
            let updatedPet = performCareAction pet action in
            let nextTurn = turn + 1 in
            debugPrint
              (Printf.sprintf
                 "Next state: turn=%d, fullness=%d, happiness=%d, energy=%d"
                 nextTurn updatedPet.fullness updatedPet.happiness
                 updatedPet.energy);
            main_loop updatedPet.name nextTurn updatedPet.fullness
              updatedPet.happiness updatedPet.energy)

(** Runs the first checkpoint. *)
let runCheckpointOne name =
  let pet = makeDefaultPet name in
  print_endline "\n--- Checkpoint 1: One-Action Pet ---";
  printStatus pet;
  printActionDescription pet feedAction;
  let fedPet = applyAction pet feedAction in
  printStatus fedPet;
  print_endline "Checkpoint 1 complete: feeding produced 75 / 55 / 45."

(** Starts the simulator. *)
let run () =
  if not debug then ignore (Sys.command "clear");
  (*Clear Terminal*)
  printWelcome ();
  let name = getPetName () in
  debugPrint (Printf.sprintf "Pet created: name=%s" name);
  if testingC1 then runCheckpointOne name
  else
    let luckyNumber = getLuckyNumber () in
    Random.init luckyNumber;
    debugPrint (Printf.sprintf "Random.init called once with %d." luckyNumber);
    let initialPet = makeDefaultPet name in
    print_endline Strings.startingStatus;
    printStatus initialPet;
    main_loop initialPet.name 1 initialPet.fullness initialPet.happiness
      initialPet.energy
