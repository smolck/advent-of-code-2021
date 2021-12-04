open Core

(*
Perhaps questionable description of how this works:

Basically just goes through each board's columns and rows, and for each
number assigns a value which is the index of where it is in the drawing list.

Then, get the max index from each row and column.

Then get the smallest of those and that number is the smallest number of
turns/draws for that board to win.

Do that for all of the boards.

Then get the minimum of those or the maximum of those for part one or two respectively,
and score it for the final answer.


Thanks to @dundargoc for this approach, the naive solution I originally thought of was
something like iterating over every board per turn and checking if it had won, but this is
better (or at least feels better).
*)

type board = { rows : int list list; cols : int list list }

type bingo = { draw : int list; boards : board list }

let make_board (input : string list) =
  let rows =
    List.map ~f:(String.split ~on:' ') input
    |> List.map ~f:(fun l ->
           List.filter ~f:(fun x -> not (String.is_empty x)) l
           |> List.map ~f:int_of_string)
  in

  (* TODO(smolck): Less manual/better way of doing this? *)
  let cols =
    [
      List.map ~f:(fun x -> List.nth_exn x 0) rows;
      List.map ~f:(fun x -> List.nth_exn x 1) rows;
      List.map ~f:(fun x -> List.nth_exn x 2) rows;
      List.map ~f:(fun x -> List.nth_exn x 3) rows;
      List.map ~f:(fun x -> List.nth_exn x 4) rows;
    ]
  in

  { rows; cols }

let read_game file =
  let lines =
    In_channel.read_all file |> String.split ~on:'\n'
    |> List.filter ~f:(fun x -> not (String.is_empty x))
  in
  let boards =
    List.sub ~pos:1 ~len:(List.length lines - 1) lines
    |> List.chunks_of ~length:5 |> List.map ~f:make_board
  in
  let draw =
    List.nth_exn lines 0 |> String.split ~on:',' |> List.map ~f:int_of_string
  in
  { draw; boards }

let max_el_exn l =
  List.max_elt ~compare:Poly.compare l |> fun x -> Option.value_exn x

(** Returns number of draws it takes to complete these rows/cols (ll) *)
let check_list (draw : int list) (ll : int list list) : int =
  let map_row row =
    let map_num num =
      let index, _ =
        List.findi ~f:(fun _ x -> phys_equal x num) draw |> fun x ->
        Option.value_exn x
      in
      index
    in
    List.map row ~f:map_num
  in

  List.map ll ~f:map_row
  |> List.map ~f:(fun l -> max_el_exn l)
  |> List.min_elt ~compare:Poly.compare
  |> fun x -> Option.value_exn x

let check_board (draw : int list) (board : board) =
  let num_of_draws_row = check_list draw board.rows in
  let num_of_draws_col = check_list draw board.cols in

  Int.min num_of_draws_row num_of_draws_col

let contains l n = List.find l ~f:(fun x -> phys_equal x n) |> Option.is_some

let sum_list l = List.fold ~init:0 ~f:(fun acc x -> acc + x) l

let score draw num_of_draws board =
  let draw_subset = List.sub ~pos:0 ~len:(num_of_draws + 1) draw in
  let all_nums = List.concat board.rows in

  let sum = List.filter all_nums ~f:(fun x -> not (contains draw_subset x)) in
  sum_list sum * List.nth_exn draw num_of_draws

let () =
  let game = read_game "input.txt" in

  (* Part one (first winning board) *)
  let i, num_of_draws, winning_board =
    List.mapi ~f:(fun i x -> (i, check_board game.draw x, x)) game.boards
    |> List.min_elt ~compare:(fun (_, x, _) (_, y, _) -> Poly.compare x y)
    |> fun x -> Option.value_exn x
  in

  let () =
    print_endline
      ("The winning board is "
      ^ string_of_int (i + 1)
      ^ " in "
      ^ string_of_int (num_of_draws + 1)
      ^ " draws")
  in
  let () =
    print_endline
      ("Final score of board: "
      ^ string_of_int (score game.draw num_of_draws winning_board))
  in

  let () = print_endline "" in

  (* Part two (last winning board) *)
  let i, num_of_draws, winning_board =
    List.mapi ~f:(fun i x -> (i, check_board game.draw x, x)) game.boards
    |> List.max_elt ~compare:(fun (_, x, _) (_, y, _) -> Poly.compare x y)
    |> fun x -> Option.value_exn x
  in

  let () =
    print_endline
      ("The last winning board is "
      ^ string_of_int (i + 1)
      ^ " in "
      ^ string_of_int (num_of_draws + 1)
      ^ " draws")
  in
  print_endline
    ("Final score of board: "
    ^ string_of_int (score game.draw num_of_draws winning_board))
