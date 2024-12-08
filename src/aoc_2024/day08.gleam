import gleam/dict.{type Dict}
import gleam/list
import gleam/option
import gleam/pair
import gleam/result
import gleam/set
import gleam/yielder
import helpers
import util/grid
import util/list_utils
import util/pair.{apply_pair} as _
import util/point.{type Point}

type Input =
  #(Dict(String, List(Point)), Point)

fn parse(data: List(String)) -> Input {
  let grid = grid.parse_grid(data)

  let antennas =
    grid
    |> list.filter(fn(pair) { pair.1 != "." })
    |> list.fold(dict.new(), fn(acc, pair) {
      let #(point, char) = pair
      use item <- dict.upsert(acc, char)

      case item {
        option.None -> [point]
        option.Some(lst) -> [point, ..lst]
      }
    })

  let bound =
    grid
    |> list.map(pair.first)
    |> list_utils.max(point.compare)
    |> result.unwrap(point.zero())

  #(antennas, bound)
}

fn in_bound(point: Point, max: Point) -> Bool {
  point.x >= 0 && point.y >= 0 && point.x <= max.x && point.y <= max.y
}

pub fn anti_node(p1: Point, p2: Point) -> Point {
  p1
  |> point.diff(p2)
  |> point.add(p2, _)
}

pub fn anti_nodes(p1: Point, p2: Point, bound: Point) -> List(Point) {
  let diff = point.diff(p1, p2)

  p2
  |> yielder.iterate(point.add(_, diff))
  |> yielder.take_while(in_bound(_, bound))
  |> yielder.to_list()
}

fn antenna_pairs(antennas: Dict(String, List(Point))) -> List(#(Point, Point)) {
  antennas
  |> dict.map_values(fn(_, points) {
    points
    |> list.combination_pairs()
    |> list.flat_map(fn(pair) { [pair, pair |> pair.swap()] })
  })
  |> dict.to_list()
  |> list.map(pair.second)
  |> list.flatten()
}

fn solve_a(input: Input) -> Int {
  let #(antennas, bound) = input

  antennas
  |> antenna_pairs()
  |> list.map(apply_pair(_, anti_node))
  |> list.filter(in_bound(_, bound))
  |> set.from_list()
  |> set.size()
}

fn solve_b(input: Input) -> Int {
  let #(antennas, bound) = input

  antennas
  |> antenna_pairs()
  |> list.flat_map(fn(pair) {
    let #(p1, p2) = pair
    anti_nodes(p1, p2, bound)
  })
  |> list.filter(in_bound(_, bound))
  |> set.from_list()
  |> set.size()
}

pub fn main() {
  helpers.run_solutions(parse, solve_a, solve_b)
}
