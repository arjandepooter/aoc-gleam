import gleam/io
import gleam/iterator
import gleam/option.{type Option}
import stdin

pub fn tee(arg: in, fn1: fn(in) -> out1, fn2: fn(in) -> out2) -> #(out1, out2) {
  #(fn1(arg), fn2(arg))
}

pub fn apply_pair(pair: #(a, b), fun: fn(a, b) -> c) -> c {
  let #(a, b) = pair
  fun(a, b)
}

pub fn run_solutions(
  parser: fn(List(String)) -> input,
  solve_a: fn(input) -> Option(String),
  solve_b: fn(input) -> Option(String),
) {
  let input =
    stdin.stdin()
    |> iterator.to_list()
    |> parser()

  let solution_a =
    input
    |> solve_a()
    |> option.unwrap("Unimplemented")
  let solution_b =
    input
    |> solve_b()
    |> option.unwrap("Unimplemented")
  io.println("Part 1: " <> solution_a)
  io.println("Part 2: " <> solution_b)
}
