import gleam/deque
import gleam/int
import gleam/list
import gleam/result
import gleam/set.{type Set}
import gleam/string
import helpers
import util/int_utils
import util/pair
import util/point.{type Point}
import util/vector

const size: Int = 70

type Input =
  List(Point)

fn parse(data: List(String)) -> Input {
  use line <- list.map(data)

  line
  |> string.split_once(",")
  |> result.unwrap(#("0", "0"))
  |> pair.map_both(int_utils.parse_or_zero)
  |> pair.apply_pair(point.Point)
}

fn in_bound(point: Point) -> Bool {
  point.x >= 0 && point.x <= size && point.y >= 0 && point.y <= size
}

fn dijkstra(
  queue: deque.Deque(#(Point, Int)),
  seen: Set(Point),
  dest: Point,
  occupied: Set(Point),
) -> Result(Int, Nil) {
  case deque.pop_front(queue) {
    Error(_) -> Error(Nil)
    Ok(#(#(point, cost), _)) if point == dest -> Ok(cost)
    Ok(#(#(point, cost), queue)) -> {
      let neighbours =
        vector.orthogonal_directions
        |> list.map(point.add(point, _))
        |> list.filter(in_bound)
        |> list.filter(fn(point) { !set.contains(occupied, point) })
        |> list.filter(fn(point) { !set.contains(seen, point) })

      let queue =
        neighbours
        |> list.map(fn(point) { #(point, cost + 1) })
        |> list.fold(queue, deque.push_back)

      let seen =
        neighbours
        |> list.fold(seen, set.insert)

      dijkstra(queue, seen, dest, occupied)
    }
  }
}

fn find_shortest_path(occupied: Set(Point)) -> Result(Int, Nil) {
  dijkstra(
    deque.from_list([#(point.zero(), 0)]),
    set.from_list([point.zero()]),
    point.Point(size, size),
    occupied,
  )
}

fn bin_search(lower: Int, upper: Int, points: List(Point)) -> Point {
  case lower, upper {
    lower, upper if upper - lower < 2 ->
      points |> list.drop(lower) |> list.first() |> result.unwrap(point.zero())
    _, _ -> {
      let to_try = { lower + upper } / 2

      let result =
        points
        |> list.take(to_try)
        |> set.from_list()
        |> find_shortest_path()

      case result {
        Error(_) -> bin_search(lower, to_try, points)
        Ok(_) -> bin_search(to_try, upper, points)
      }
    }
  }
}

fn solve_a(input: Input) -> Int {
  input
  |> list.take(1024)
  |> set.from_list()
  |> find_shortest_path()
  |> result.unwrap(0)
}

fn solve_b(input: Input) -> String {
  let point.Point(x, y) =
    input
    |> bin_search(1024, list.length(input), _)

  [x, y]
  |> list.map(int.to_string)
  |> string.join(",")
}

pub fn main() {
  helpers.run_solutions(parse, solve_a, solve_b)
}
