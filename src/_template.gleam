import gleam/iterator.{type Iterator}
import gleam/option.{type Option}
import helpers

type Input =
  String

fn parse(data: List(String)) -> Input {
  todo
}

fn solve_a(input: Input) -> Option(String) {
  option.None
}

fn solve_b(input: Input) -> Option(String) {
  option.None
}

pub fn main() {
  helpers.run_solutions(parse, solve_a, solve_b)
}
