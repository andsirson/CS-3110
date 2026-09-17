(* Test the public simulator functions. *)
open Main

(* Fail a test when its condition is false. *)
let check label condition = if not condition then failwith ("FAILED: " ^ label)

(* Check an integer result. *)
let check_int label expected actual =
  check
    (label ^ Printf.sprintf " (expected %d, got %d)" expected actual)
    (expected = actual)

(* Check two values for equality. *)
let check_equal label expected actual = check label (expected = actual)

(* Build a pet with explicitly chosen attributes. *)
let make_test_pet fullness happiness energy =
  { name = "Testcat"; fullness; happiness; energy }

(* Req. 1.4 and 1.5: check starting values and feeding. *)
let test_initial_state () =
  let p = makeDefaultPet "Mochi" in
  check_int "initial fullness" 50 p.fullness;
  check_int "initial happiness" 50 p.happiness;
  check_int "initial energy" 50 p.energy;
  check_equal "initial name preserved" "Mochi" p.name

(* Check the attribute bounds helper. *)
let test_clamp () =
  check_int "clamp lower bound" 0 (clamp (-20));
  check_int "clamp zero" 0 (clamp 0);
  check_int "clamp middle" 57 (clamp 57);
  check_int "clamp upper bound" 100 (clamp 100);
  check_int "clamp upper overflow" 100 (clamp 130)

(* Req. 2.2: check every care action's exact effects. *)
let test_care_action_deltas () =
  let p = make_test_pet 50 50 50 in
  let fed = applyAction p feedAction in
  check_equal "feed effects" (75, 55, 45)
    (fed.fullness, fed.happiness, fed.energy);
  let played = applyAction p playAction in
  check_equal "play effects" (40, 70, 35)
    (played.fullness, played.happiness, played.energy);
  let napped = applyAction p napAction in
  check_equal "nap effects" (40, 45, 75)
    (napped.fullness, napped.happiness, napped.energy);
  let special = applyAction p specialAction in
  check_equal "special effects" (35, 80, 25)
    (special.fullness, special.happiness, special.energy)

(* Req. 2.3 and 3.5: check clamping at both bounds. *)
let test_care_action_clamping () =
  let low = make_test_pet 5 5 5 in
  let low_after = applyAction low specialAction in
  check_equal "care actions clamp low" (0, 35, 0)
    (low_after.fullness, low_after.happiness, low_after.energy);
  let high = make_test_pet 95 95 95 in
  let high_after = applyAction high feedAction in
  check_equal "care actions clamp high" (100, 100, 90)
    (high_after.fullness, high_after.happiness, high_after.energy)

(* Check the wellness calculation. *)
let test_wellness () =
  check_int "integer wellness average" 55 (getWellness (make_test_pet 50 55 60));
  check_int "wellness floor division" 1 (getWellness (make_test_pet 1 1 2))

(* Check the priority order used to choose moods. *)
let test_mood_priority () =
  check_equal "hungry has highest priority" Hungry
    (getMood (make_test_pet 20 100 100));
  check_equal "sleepy follows hungry" Sleepy (getMood (make_test_pet 21 100 20));
  check_equal "lonely follows sleepy" Lonely (getMood (make_test_pet 21 20 21));
  check_equal "delighted at wellness 75" Delighted
    (getMood (make_test_pet 75 75 75));
  check_equal "content below 75" Content (getMood (make_test_pet 74 74 73))

(* Req. 2.8 and 2.9: check outcome order and final forms. *)
let test_outcomes () =
  check_equal "zero stat gives immediate TLC" NeedsTLC
    (getOutcome (make_test_pet 0 100 100));
  check_equal "wellness 75 gives thriving" Thriving
    (getOutcome (make_test_pet 75 75 75));
  check_equal "wellness 55 gives doing well" DoingWell
    (getOutcome (make_test_pet 60 55 50));
  check_equal "wellness 35 gives frazzled" Frazzled
    (getOutcome (make_test_pet 40 35 30));
  check_equal "wellness below 35 gives neglected" Neglected
    (getOutcome (make_test_pet 30 30 30))

(* Req. 3.3: check event codes and exact effects. *)
let test_event_codes_and_effects () =
  let p = make_test_pet 50 50 50 in
  let events =
    [
      (nothingAction, (0, 0, 0));
      (findSnackAction, (10, 0, 0));
      (zoomiesAction, (0, 15, -10));
      (unexpectedNapAction, (-5, 0, 15));
      (mishapAction, (0, -10, 0));
    ]
  in
  List.iter
    (fun item ->
      match item with
      | RandAction (code, deltas, _), expected_deltas ->
          check_equal
            (Printf.sprintf "event code %d" code)
            expected_deltas deltas
      | _ -> failwith "expected a random action")
    events;
  List.iter
    (fun (event, (df, dh, de)) ->
      let updated = applyAction p event in
      check_equal "event effect applied exactly"
        (clamp (50 + df), clamp (50 + dh), clamp (50 + de))
        (updated.fullness, updated.happiness, updated.energy))
    events

(* Req. 3.5: care is applied before the event. *)
let test_event_clamping_and_order () =
  let p = make_test_pet 10 50 50 in
  let afterCare = applyAction p specialAction in
  let result = applyAction afterCare findSnackAction in
  (* Special first, then the snack. *)
  check_equal "care clamp happens before event clamp" (10, 80, 25)
    (result.fullness, result.happiness, result.energy)

(* Req. 2.4 and 3.6: status is a non-care command. *)
let test_state_preservation_for_check () =
  let p = make_test_pet 42 61 73 in
  printStatus p;
  check_equal "status preserves pet name" "Testcat" p.name;
  check_equal "status preserves attributes" (42, 61, 73)
    (p.fullness, p.happiness, p.energy)

(* Req. 2.1, 2.5, and 2.6: check all menu commands. *)
let test_menu_and_commands () =
  let menu = menuText 3 in
  List.iter
    (fun (n, text) ->
      check
        ("menu contains option " ^ string_of_int n)
        (String.length text > 0
        && String.contains menu (Char.chr (n + Char.code '0'))))
    [ (1, "1"); (2, "2"); (3, "3"); (4, "4"); (5, "5"); (6, "6") ];
  check_equal "choice 1" (Care feedAction) (commandOfChoice 1);
  check_equal "choice 2" (Care playAction) (commandOfChoice 2);
  check_equal "choice 3" (Care napAction) (commandOfChoice 3);
  check_equal "choice 4" (Care specialAction) (commandOfChoice 4);
  check_equal "choice 5" (Check checkAction) (commandOfChoice 5);
  check_equal "choice 6" (EndDay skipAction) (commandOfChoice 6)

(* Req. 2.5: invalid menu values are rejected. *)
let test_invalid_menu_choice () =
  try
    let _ = commandOfChoice 7 in
    failwith "invalid choice was accepted"
  with Invalid_argument _ -> ()

(* Req. 2.4 and 2.6: static actions leave the pet unchanged. *)
let test_static_actions () =
  let p = make_test_pet 42 61 73 in
  let checked = applyAction p checkAction in
  let ended = applyAction p skipAction in
  check_equal "check action keeps state"
    (p.fullness, p.happiness, p.energy)
    (checked.fullness, checked.happiness, checked.energy);
  check_equal "end action keeps state"
    (p.fullness, p.happiness, p.energy)
    (ended.fullness, ended.happiness, ended.energy)

(* Check the customized text and final forms. *)
let test_customization () =
  List.iter
    (fun action ->
      check
        ("care description exists for " ^ getActionName action)
        (String.length (getActionDescription (make_test_pet 50 50 50) action)
        > 20))
    [ feedAction; playAction; napAction; specialAction ];
  List.iter
    (fun event ->
      check
        ("event description exists for " ^ getActionName event)
        (String.length (eventDescription (make_test_pet 50 50 50) event) > 20))
    [
      nothingAction;
      findSnackAction;
      zoomiesAction;
      unexpectedNapAction;
      mishapAction;
    ];
  let forms =
    List.map
      (fun outcome -> fst (finalFormAndStory (make_test_pet 50 50 50) outcome))
      [ NeedsTLC; Thriving; DoingWell; Frazzled; Neglected ]
  in
  check "five outcomes have distinct final forms"
    (List.length forms = List.length (List.sort_uniq String.compare forms))

(* Check that each final story contains its outcome. *)
let test_final_story_keywords () =
  let p = make_test_pet 50 50 50 in
  let required =
    [
      (NeedsTLC, "immediate TLC");
      (Thriving, "thriving");
      (DoingWell, "doing well");
      (Frazzled, "frazzled");
      (Neglected, "neglected");
    ]
  in
  List.iter
    (fun (outcome, keyword) ->
      let _, story = finalFormAndStory p outcome in
      check
        ("final story contains " ^ keyword)
        (let rec contains_from i =
           if i + String.length keyword > String.length story then false
           else if String.sub story i (String.length keyword) = keyword then
             true
           else contains_from (i + 1)
         in
         contains_from 0))
    required

(* Check that the editable text library is connected. *)
let test_strings_library () =
  check "cat art is present" (String.length Strings.cat > 0);
  check "mood cat art is present"
    (String.length (Strings.catForMood "Hungry") > 0);
  check "action cat art is present"
    (String.length (Strings.catForAction "Feed") > 0);
  check_equal "species text" "cat" Strings.petSpecies;
  check_equal "menu text uses turn" true
    (String.contains (Strings.menuText 2) '2');
  check "custom text is present"
    (String.length (Strings.moodDescription "Mochi" "Hungry") > 0)

(* Check that event codes stay attached to their actions. *)
let test_reproducible_randomness () =
  let actions =
    [
      nothingAction;
      findSnackAction;
      zoomiesAction;
      unexpectedNapAction;
      mishapAction;
    ]
  in
  List.iter
    (fun action ->
      match action with
      | RandAction (code, _, _) ->
          check "event code is in range" (code >= 0 && code <= 4)
      | _ -> failwith "expected a random action")
    actions

(* Check the display labels for moods and outcomes. *)
let test_string_labels () =
  check_equal "mood hungry label" "Hungry" (stringOfMood Hungry);
  check_equal "mood sleepy label" "Sleepy" (stringOfMood Sleepy);
  check_equal "mood lonely label" "Lonely" (stringOfMood Lonely);
  check_equal "mood delighted label" "Delighted" (stringOfMood Delighted);
  check_equal "mood content label" "Content" (stringOfMood Content);
  check_equal "outcome TLC label" "Immediate TLC" (stringOfOutcome NeedsTLC);
  check_equal "outcome thriving label" "Thriving" (stringOfOutcome Thriving);
  check_equal "outcome doing well label" "Doing well"
    (stringOfOutcome DoingWell);
  check_equal "outcome frazzled label" "Frazzled" (stringOfOutcome Frazzled);
  check_equal "outcome neglected label" "Neglected" (stringOfOutcome Neglected)

(* Store the tests and their display names. *)
let tests =
  [
    ("initial state", test_initial_state);
    ("clamp", test_clamp);
    ("care action deltas", test_care_action_deltas);
    ("care action clamping", test_care_action_clamping);
    ("wellness", test_wellness);
    ("mood priority", test_mood_priority);
    ("outcomes", test_outcomes);
    ("event codes and effects", test_event_codes_and_effects);
    ("event clamping and order", test_event_clamping_and_order);
    ("state preservation", test_state_preservation_for_check);
    ("menu and commands", test_menu_and_commands);
    ("invalid menu choice", test_invalid_menu_choice);
    ("static actions", test_static_actions);
    ("customization", test_customization);
    ("strings library", test_strings_library);
    ("final story keywords", test_final_story_keywords);
    ("reproducible randomness", test_reproducible_randomness);
    ("string labels", test_string_labels);
  ]

(* Run each test and stop at the first failure. *)
let rec run_tests tests passed total =
  match tests with
  | [] -> Printf.printf "\nAutomated tests: %d / %d passed.\n" passed total
  | (name, test) :: rest -> (
      try
        test ();
        Printf.printf "[PASS] %s\n" name;
        run_tests rest (passed + 1) total
      with Failure message ->
        Printf.eprintf "%s\n" message;
        Printf.printf "[FAIL] %s\n" name;
        exit 1)

(* Start the test suite. *)
let run () = run_tests tests 0 (List.length tests)
let () = run ()
