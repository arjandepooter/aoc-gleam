import gleam/dict.{type Dict}
import gleam/float
import gleam/int
import gleam/list
import gleam/option
import gleam/result
import gleam/string
import gleam/yielder
import helpers
import util/int_utils

type Input =
  List(Int)

fn parse(data: List(String)) -> Input {
  use line <- list.flat_map(data)

  line
  |> string.split(" ")
  |> list.map(int_utils.parse_or_zero)
}

fn split(n: Int) -> #(Int, Int) {
  let d =
    n
    |> int_utils.number_of_digits()
    |> int.divide(2)
    |> result.unwrap(1)
    |> int.to_float()
    |> int.power(10, _)
    |> result.unwrap(1.0)
    |> float.truncate()

  #(n / d, n % d)
}

fn grow(lst: List(Int)) -> List(Int) {
  use n <- list.flat_map(lst)

  let num_digits = int_utils.number_of_digits(n)

  case n, int.is_even(num_digits) {
    0, _ -> [1]
    n, True -> {
      let #(a, b) = n |> split()
      [a, b]
    }
    n, False -> [n * 2024]
  }
}

fn to_count(lst: List(Int)) -> Dict(Int, Int) {
  use acc, value <- list.fold(lst, dict.new())
  use result <- dict.upsert(acc, value)
  case result {
    option.Some(size) -> size + 1
    _ -> 1
  }
}

fn counting_grow(lst: Dict(Int, Int)) -> Dict(Int, Int) {
  lst
  |> dict.to_list()
  |> list.flat_map(fn(item) {
    let #(value, size) = item
    use stone <- list.map(grow([value]))

    #(stone, size)
  })
  |> list.fold(dict.new(), fn(acc, item) {
    let #(value, size) = item
    use result <- dict.upsert(acc, value)

    case result {
      option.Some(cur_size) -> cur_size + size
      _ -> size
    }
  })
}

fn solve_a(input: Input) -> Int {
  input
  |> to_count()
  |> yielder.iterate(counting_grow)
  |> yielder.at(25)
  |> result.unwrap(dict.new())
  |> dict.values()
  |> int.sum()
}

fn solve_b(input: Input) -> Int {
  input
  |> to_count()
  |> yielder.iterate(counting_grow)
  |> yielder.at(75)
  |> result.unwrap(dict.new())
  |> dict.values()
  |> int.sum()
}

pub fn main() {
  helpers.run_solutions(parse, solve_a, solve_b)
}
