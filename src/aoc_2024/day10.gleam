import gleam/dict
import gleam/int
import gleam/list
import gleam/pair
import gleam/set
import helpers
import util/grid.{type Grid}
import util/int_utils
import util/point.{type Point}

type Input =
  Grid(Int)

fn parse(data: List(String)) -> Input {
  data
  |> grid.parse_grid()
  |> list.map(pair.map_second(_, int_utils.parse_or_zero))
  |> dict.from_list()
}

fn trails(start: Point, grid: Grid(Int)) -> List(List(Point)) {
  case dict.get(grid, start) {
    Ok(9) -> [[start]]
    Ok(value) -> {
      start
      |> grid.filter_neighbours(grid, fn(_, next) { next - value == 1 })
      |> list.map(pair.first)
      |> list.map(trails(_, grid))
      |> list.fold([], fn(acc, result) {
        acc
        |> list.append(list.map(result, list.prepend(_, start)))
      })
    }
    _ -> []
  }
}

fn trail_score(start: Point, grid: Grid(Int)) -> Int {
  start
  |> trails(grid)
  |> list.filter_map(list.last)
  |> set.from_list()
  |> set.size()
}

fn trail_rating(start: Point, grid: Grid(Int)) -> Int {
  start
  |> trails(grid)
  |> list.length()
}

fn solve_a(input: Input) -> Int {
  input
  |> dict.filter(fn(_, n) { n == 0 })
  |> dict.keys()
  |> list.map(trail_score(_, input))
  |> int.sum()
}

fn solve_b(input: Input) -> Int {
  input
  |> dict.filter(fn(_, n) { n == 0 })
  |> dict.keys()
  |> list.map(trail_rating(_, input))
  |> int.sum()
}

pub fn main() {
  helpers.run_solutions(parse, solve_a, solve_b)
}
