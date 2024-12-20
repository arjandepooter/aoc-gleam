import gleam/bool
import gleam/dict
import gleam/list
import gleam/pair
import gleam/result
import gleam/set.{type Set}
import helpers
import util/grid.{type Grid}
import util/point.{type Point}

const cheat_threshold = 100

type Cell {
  Wall
  Path
}

type Input =
  #(Grid(Cell), Point, Point)

fn parse(data: List(String)) -> Input {
  let grid =
    data
    |> grid.parse_grid()

  let start = find_point(grid, "S")
  let finish = find_point(grid, "E")
  let grid =
    grid
    |> dict.from_list()
    |> dict.map_values(fn(_, value) {
      case value {
        "#" -> Wall
        _ -> Path
      }
    })

  #(grid, start, finish)
}

fn find_point(grid: List(#(Point, String)), char: String) -> Point {
  grid
  |> list.map(pair.swap)
  |> list.key_find(char)
  |> result.unwrap(point.zero())
}

fn find_path(
  grid: Grid(Cell),
  current: Point,
  finish: Point,
  acc: List(Point),
  seen: Set(Point),
) -> List(Point) {
  use <- bool.guard(current == finish, acc)

  let next =
    current
    |> grid.filter_neighbours(grid, fn(point, cell) {
      !set.contains(seen, point) && cell == Path
    })
    |> list.first()
    |> result.lazy_unwrap(fn() { panic })
    |> pair.first()

  find_path(grid, next, finish, [next, ..acc], set.insert(seen, next))
}

fn find_path_costs(
  grid: Grid(Cell),
  start: Point,
  finish: Point,
) -> List(#(Point, Int)) {
  grid
  |> find_path(start, finish, [start], set.from_list([start]))
  |> list.reverse()
  |> list.index_map(pair.new)
}

fn find_cheats(
  path: List(#(Point, Int)),
  max_cheat_duration: Int,
  acc: List(#(Point, Point)),
) -> List(#(Point, Point)) {
  case path {
    [] -> acc
    [#(from, cost), ..path] -> {
      path
      |> list.drop(cheat_threshold)
      |> list.filter(fn(item) {
        let #(point, other_cost) = item
        let distance = point.manhattan(from, point)

        distance <= max_cheat_duration
        && other_cost - cost - distance >= cheat_threshold
      })
      |> list.map(pair.map_second(_, fn(_) { from }))
      |> list.append(acc)
      |> find_cheats(path, max_cheat_duration, _)
    }
  }
}

fn solve_a(input: Input) -> Int {
  let #(grid, start, finish) = input

  grid
  |> find_path_costs(start, finish)
  |> find_cheats(2, [])
  |> list.length()
}

fn solve_b(input: Input) -> Int {
  let #(grid, start, finish) = input

  grid
  |> find_path_costs(start, finish)
  |> find_cheats(20, [])
  |> list.length()
}

pub fn main() {
  helpers.run_solutions(parse, solve_a, solve_b)
}
