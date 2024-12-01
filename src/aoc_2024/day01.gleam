import gleam/bool
import gleam/int
import gleam/list
import gleam/option.{type Option}
import gleam/result
import gleam/string
import helpers

type Input =
  #(List(Int), List(Int))

fn parse(data: List(String)) -> Input {
  let lines =
    data
    |> list.map(string.trim)
    |> list.filter(fn(line) { string.length(line) > 0 })

  let assert [l1, l2, ..] =
    {
      use line <- list.map(lines)

      line
      |> string.split("   ")
      |> list.map(int.parse)
      |> list.map(result.unwrap(_, 0))
    }
    |> list.transpose()

  #(l1, l2)
}

fn solve_a(input: Input) -> Option(String) {
  let #(l1, l2) = input
  let assert [l1, l2] =
    [l1, l2]
    |> list.map(list.sort(_, int.compare))

  l1
  |> list.zip(l2)
  |> list.map(fn(ns) {
    let #(n1, n2) = ns
    int.absolute_value(n1 - n2)
  })
  |> int.sum()
  |> int.to_string()
  |> option.Some
}

fn solve_b(input: Input) -> Option(String) {
  let #(l1, l2) = input

  {
    use n1 <- list.map(l1)

    let counts =
      l2
      |> list.count(fn(n2) { n1 == n2 })
    counts * n1
  }
  |> int.sum()
  |> int.to_string()
  |> option.Some
}

pub fn main() {
  helpers.run_solutions(parse, solve_a, solve_b)
}
