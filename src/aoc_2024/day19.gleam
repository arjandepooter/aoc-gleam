import gleam/bool
import gleam/dict.{type Dict}
import gleam/int
import gleam/list
import gleam/pair
import gleam/string
import helpers

type Input =
  #(List(String), List(String))

fn parse(data: List(String)) -> Input {
  let assert [towels, _, ..patterns] = data
  let towels = string.split(towels, ", ")
  let patterns =
    patterns
    |> list.filter(fn(line) { !string.is_empty(line) })

  #(towels, patterns)
}

fn memoized(
  pattern: String,
  towels: List(String),
  cache: Dict(String, Int),
) -> #(Int, Dict(String, Int)) {
  use <- bool.guard(string.is_empty(pattern), #(1, cache))

  case dict.get(cache, pattern) {
    Ok(value) -> #(value, cache)
    _ -> {
      use acc, towel <- list.fold(towels, #(0, cache))
      use <- bool.guard(!string.starts_with(pattern, towel), acc)

      let #(n, cache) = acc

      let next_pattern =
        pattern
        |> string.drop_start(string.length(towel))

      let #(result, cache) =
        next_pattern
        |> memoized(towels, cache)

      let cache =
        cache
        |> dict.insert(next_pattern, result)

      #(result + n, cache)
    }
  }
}

fn possible(pattern: String, towels: List(String)) -> Int {
  pattern
  |> memoized(towels, dict.new())
  |> pair.first()
}

fn solve_a(input: Input) -> Int {
  let #(towels, patterns) = input

  patterns
  |> list.map(possible(_, towels))
  |> list.filter(fn(result) { result > 0 })
  |> list.length()
}

fn solve_b(input: Input) -> Int {
  let #(towels, patterns) = input

  patterns
  |> list.map(possible(_, towels))
  |> int.sum()
}

pub fn main() {
  helpers.run_solutions(parse, solve_a, solve_b)
}
