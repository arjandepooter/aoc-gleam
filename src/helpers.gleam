import gleam/dynamic
import gleam/int
import gleam/io
import gleam/list
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

fn solution_to_string(solution: dynamic.Dynamic) -> String {
  let parser =
    dynamic.any([
      dynamic.string,
      fn(d) {
        d
        |> dynamic.int()
        |> result.map(int.to_string)
      },
    ])

  solution
  |> parser()
  |> result.lazy_unwrap(fn() { panic as "Solution should return String or Int" })
}

pub fn run_solutions(
  parser: fn(List(String)) -> input,
  solve_a: fn(input) -> a,
  solve_b: fn(input) -> b,
) {
  let input =
    stdin()
    |> yielder.to_list()
    |> list.map(string.trim_end)
    |> parser()

  let solution_a =
    input
    |> solve_a()
    |> dynamic.from()

  let solution_b =
    input
    |> solve_b()
    |> dynamic.from()

  io.println("Part 1: " <> solution_to_string(solution_a))
  io.println("Part 2: " <> solution_to_string(solution_b))
}
