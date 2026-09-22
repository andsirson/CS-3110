(* Handles command-line arguments, terminal communication, and exit statu *)

let getMenuChoice () =
  try
    let choice = int_of_string (String.trim (read_line ())) in
    if choice >= 1 && choice <= 6 then Some choice else None
  with Failure _ -> None

let () =
  if Array.length Sys.argv <> 3 then begin
    Printf.printf "Usage: %s <input_file> <output_file>\n" Sys.argv.(0);
    exit 1
  end;

  let input_file = Sys.argv.(1) in
  let output_file = Sys.argv.(2) in

  print_endline input_file;
  print_endline output_file
