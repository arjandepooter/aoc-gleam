import gleam/dynamic
import gleam/io
import gleam/list
import gleam/option.{type Option}
import gleam/result
import gleam/string
import gleam/yielder

@external(erlang, "io", "get_line")
fn ffi_read_line(prompt: String) -> dynamic.Dynamic

fn read_line() -> Result(String, Nil) {
  ffi_read_line("")
  |> dynamic.from()
  |> dynamic.string()
  |> result.replace_error(Nil)
}

fn stdin() -> yielder.Yielder(String) {
  yielder.repeatedly(read_line)
  |> yielder.take_while(result.is_ok)
  |> yielder.map(result.unwrap(_, ""))
}

pub fn run_solutions(
  parser: fn(List(String)) -> input,
  solve_a: fn(input) -> Option(String),
  solve_b: fn(input) -> Option(String),
) {
  let input =
    stdin()
    |> yielder.to_list()
    |> list.map(string.trim_end)
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
