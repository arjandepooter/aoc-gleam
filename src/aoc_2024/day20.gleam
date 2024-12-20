import gleam/bool
import gleam/dict.{type Dict}
import gleam/list
import gleam/pair
import gleam/result
import gleam/set.{type Set}
import helpers
import util/grid.{type Grid}
import util/point.{type Point}

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
) -> Dict(Point, Int) {
  grid
  |> find_path(start, finish, [start], set.from_list([start]))
  |> list.reverse()
  |> list.index_map(pair.new)
  |> dict.from_list()
}

fn find_cheats_for_point(
  from: Point,
  path_costs: Dict(Point, Int),
  max_cheat_duration: Int,
) -> List(Point) {
  let assert Ok(cost) = dict.get(path_costs, from)

  path_costs
  |> dict.filter(fn(point, other_cost) {
    let distance = point.manhattan(from, point)
    distance <= max_cheat_duration && other_cost - cost - distance >= 100
  })
  |> dict.keys()
}

fn find_cheats(
  path_costs: Dict(Point, Int),
  max_cheat_duration: Int,
) -> List(#(Point, Point)) {
  path_costs
  |> dict.keys()
  |> list.flat_map(fn(point) {
    point
    |> find_cheats_for_point(path_costs, max_cheat_duration)
    |> list.map(pair.new(point, _))
  })
}

fn solve_a(input: Input) -> Int {
  let #(grid, start, finish) = input

  grid
  |> find_path_costs(start, finish)
  |> find_cheats(2)
  |> list.map(pair.first)
  |> list.length()
}

fn solve_b(input: Input) -> Int {
  let #(grid, start, finish) = input

  grid
  |> find_path_costs(start, finish)
  |> find_cheats(20)
  |> list.length()
}

pub fn main() {
  helpers.run_solutions(parse, solve_a, solve_b)
}
