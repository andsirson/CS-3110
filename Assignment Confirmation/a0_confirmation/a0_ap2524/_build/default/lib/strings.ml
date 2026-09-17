(* Text and ASCII art used by the virtual pet simulator *)
(* ASCII from www.asciiart.eu *)

let petSpecies = "cat"
let cat = " /\\_/\\\n( o.o )\n > ^ <"

let tiredCat =
  {|
  __..--''``---....___   _..._    __
 /// //_.-'    .-/;  `        ``<._  ``.''_ `. / // /
///_.-' _..--.'_                        `( ) ) // //
/ (_..-' // (< _     ;_..__               ; `' / ///
 / // // //  `-._,_)' // / ``--...____..-' /// / //
|}

let goofyCat =
  {|
      |\      _,,,---,,_
ZZZzz /,`.-'`'    -.  ;-;;,_
     |,4-  ) )-,_. ,\ (  `'-'
    '---''(_/--'  `-'\_)  
|}

let anotherCat =
  {|
 |\__/,|   (`\
 |_ _  |.--.) )
 ( T   )     /
(((^_(((/(((_/
|}

let scaredCat =
  {|
         
    / ) 
   / /  
  / /               /\ 
 / /     .-```-.   / ^`-.  
 \ \    /       \_/  (|) `o 
  \ \  /   .-.   \\ _  ,--' 
   \ \/   /   )   \( `^^^  
    \   \/    (    )  
     \   )     )  /     
   ) /__    | (__  
     (___)))   (__))) 
|}

let neutralCat =
  {|
                        _
                       | \
                       | |
                       | |
  |\                   | |
 /, ~\                / /
X     `-.....-------./ /
 ~-. ~  ~              |
    \             /    |
     \  /_     ___\   /
     | /\ ~~~~~   \ |
     | | \        || |
     | |\ \       || )
    (_/ (_/      ((_/
|}

let playfulCat =
  {|
  ,-.       _,---._ __  / \
 /  )    .-'       `./ /   \
(  (   ,'            `/    /|
 \  `-"             \'\   / |
  `.              ,  \ \ /  |
   /`.          ,'-`----Y   |
  (            ;        |   '
  |  ,-.    ,-'         |  /
  |  | (   |            | /
  )  |  \  `.___________|/
  `--'   `--'
|}

let catForMood mood =
  match mood with
  | "Hungry" -> scaredCat
  | "Sleepy" -> tiredCat
  | "Lonely" -> anotherCat
  | "Delighted" -> playfulCat
  | _ -> neutralCat

let catForAction action =
  match action with
  | "Feed" -> goofyCat
  | "Play" -> playfulCat
  | "Nap" -> tiredCat
  | _ -> anotherCat

(* Pet-specific descriptions. *)
let moodDescription name mood =
  match mood with
  | "Hungry" ->
      Printf.sprintf "%s has NEVER been fed, EVER (they swear), and is hungry."
        name
  | "Sleepy" ->
      Printf.sprintf "%s is looking for somewhere to nap. Me too tbh" name
  | "Lonely" ->
      Printf.sprintf "%s is feeling lonely :(. Go hug them you evil monster!"
        name
  | "Delighted" -> Printf.sprintf "%s is bouncing around happily. Yippee!!" name
  | _ ->
      Printf.sprintf "%s looks comfortable. They are hitting a 10/10 loaf." name

let actionDescription name action =
  match action with
  | "Feed" -> Printf.sprintf "%s eats a fresh meal. Nom Nom Nom" name
  | "Play" ->
      Printf.sprintf
        "%s chases a laser pointer around the room, like Sisyphus in a way" name
  | "Nap" -> Printf.sprintf "%s curls up for a nap. We are all so jealous." name
  | _ -> Printf.sprintf "meow meow mrrp meow mrrp meowww"

let eventDescription name event =
  match event with
  | "NothingUnusual" -> Printf.sprintf "%s slow blinks at you." name
  | "FoundSnack" -> Printf.sprintf "%s breaks into the food bag. Uhoh!" name
  | "Zoomies" ->
      Printf.sprintf "%s gets the zoomies at 3am. -10 sanity for you." name
  | "UnexpectedNap" -> Printf.sprintf "%s falls asleep in the sun. bum ahh" name
  | _ -> Printf.sprintf "%s knocks over a vase. It's a disaster!" name

let finalFormAndStory name outcome =
  match outcome with
  | "NeedsTlc" ->
      ( "Scruffy Cat",
        Printf.sprintf
          "%s needs immediate TLC and some extra care. Frankly, they should be \
           given to someone else, you monster."
          name )
  | "Thriving" ->
      ( "Stinky Winky Cat",
        Printf.sprintf
          "%s is thriving and doing great. You call them stinky in response."
          name )
  | "DoingWell" ->
      ( "Cat in a Hat",
        Printf.sprintf "%s is doing well. Your couch, however..." name )
  | "Frazzled" ->
      ( "Kitty in a Tizzy",
        Printf.sprintf "%s is looking a little frazzled. Lock in." name )
  | _ ->
      ( "Irritated Kitty",
        Printf.sprintf
          "%s has been neglected and needs more attention. You suck. How could \
           you. smh."
          name )

(* Menu and game text *)
let menuText turn =
  Printf.sprintf "\n========== Turn %d / 5 ==========%s\n" turn
    "\n\
     1. Feed your cat\n\
     2. Play with your cat\n\
     3. Let your cat nap\n\
     4. Catnip Chase (nyoom) \n\
     5. Check on your cat\n\
     6. End the day early\n\n\
     Choose 1-6: "

let welcome =
  {|
========================================
      MEOW MEOW MEOW MEOW MEOW :3               
========================================
Welcome! Take care of your cat today.
    |}

let closing = "\nThanks for playing!"
let namePrompt = "What would you like to name your cat?   "
let emptyName = "Please enter a name.   "
let luckyNumberPrompt = "Choose a lucky number:   "
let invalidLuckyNumber = "Please enter a valid integer."
let startingStatus = "\nHere is your cat's starting status:"
let invalidChoice = "Invalid choice. Please enter a number from 1 through 6."
