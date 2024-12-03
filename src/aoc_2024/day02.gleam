import gleam/function
import gleam/int
import gleam/list
import gleam/option.{type Option}
import gleam/result
import gleam/string
import helpers

type Input =
  List(List(Int))

fn parse(data: List(String)) -> Input {
  let lines =
    data
    |> list.map(string.trim)
    |> list.filter(fn(line) { string.length(line) > 0 })
  use line <- list.map(lines)

  line
  |> string.split(" ")
  |> list.map(int.parse)
  |> list.map(result.unwrap(_, 0))
}

fn is_safe(report: List(Int)) -> Bool {
  let report = case report {
    [a, b, ..] if a > b ->
      report
      |> list.reverse()
    report -> report
  }

  {
    use a, b <- list.map2(report, list.drop(report, 1))
    a < b && b - a <= 3
  }
  |> list.all(function.identity)
}

fn solve_a(input: Input) -> Option(String) {
  input
  |> list.filter(is_safe)
  |> list.length()
  |> int.to_string()
  |> option.Some()
}

fn is_tolerant_safe(report: List(Int)) -> Bool {
  report
  |> list.index_map(fn(_, idx) {
    report
    |> list.take(idx)
    |> list.append(list.drop(report, idx + 1))
  })
  |> list.any(is_safe)
}

fn solve_b(input: Input) -> Option(String) {
  input
  |> list.filter(is_tolerant_safe)
  |> list.length()
  |> int.to_string()
  |> option.Some()
}

pub fn main() {
  helpers.run_solutions(parse, solve_a, solve_b)
}
