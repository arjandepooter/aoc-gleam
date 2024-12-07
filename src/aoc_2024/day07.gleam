import gleam/int
import gleam/list
import gleam/option.{type Option}
import gleam/pair
import gleam/result
import gleam/string
import helpers

type Input =
  List(#(Int, List(Int)))

fn parse(data: List(String)) -> Input {
  use line <- list.map(data)

  let #(result, values) =
    line
    |> string.split_once(": ")
    |> result.unwrap(#("0", "0"))

  let result =
    result
    |> int.parse()
    |> result.unwrap(0)

  let values =
    values
    |> string.split(" ")
    |> list.map(int.parse)
    |> list.map(result.unwrap(_, 0))

  #(result, values)
}

fn permutations(
  options: List(a),
  length: Int,
  acc: List(List(a)),
) -> List(List(a)) {
  case length {
    0 -> acc
    n if n < 0 -> panic
    _ -> {
      let acc = {
        use cur <- list.flat_map(acc)
        use op <- list.map(options)

        [op, ..cur]
      }

      permutations(options, length - 1, acc)
    }
  }
}

fn is_valid_test(
  result: Int,
  values: List(Int),
  operators: List(fn(Int, Int) -> Int),
) -> Bool {
  let length = list.length(values)
  let perms = permutations(operators, length - 1, [[]])

  use operators <- list.any(perms)

  let test_result =
    operators
    |> list.prepend(int.add)
    |> list.zip(values)
    |> list.fold(0, fn(acc, pair) {
      let #(op, value) = pair
      op(acc, value)
    })

  test_result == result
}

fn concat(a: Int, b: Int) -> Int {
  { int.to_string(a) <> int.to_string(b) }
  |> int.parse()
  |> result.unwrap(0)
}

fn solve_a(input: Input) -> Option(String) {
  input
  |> list.filter(fn(pair) {
    let #(result, values) = pair
    is_valid_test(result, values, [int.add, int.multiply])
  })
  |> list.map(pair.first)
  |> int.sum()
  |> int.to_string()
  |> option.Some
}

fn solve_b(input: Input) -> Option(String) {
  input
  |> list.filter(fn(pair) {
    let #(result, values) = pair
    is_valid_test(result, values, [int.add, int.multiply, concat])
  })
  |> list.map(pair.first)
  |> int.sum()
  |> int.to_string()
  |> option.Some
}

pub fn main() {
  helpers.run_solutions(parse, solve_a, solve_b)
}
