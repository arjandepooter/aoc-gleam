import gleam/dict.{type Dict}
import gleam/int
import gleam/list
import gleam/option
import gleam/pair
import gleam/result
import gleam/set.{type Set}
import gleamy/priority_queue
import helpers
import util/grid
import util/list_utils
import util/point.{type Point}
import util/vector.{type Vector}

type Input =
  #(Set(Point), Point, Point)

type Position {
  Position(position: Point, direction: Vector)
}

fn parse(data: List(String)) -> Input {
  let grid =
    data
    |> grid.parse_grid()

  let walls =
    grid
    |> list.filter_map(fn(ch) {
      case ch {
        #(point, "#") -> Ok(point)
        _ -> Error(Nil)
      }
    })
    |> set.from_list()

  let start = find_point(grid, "S")
  let end = find_point(grid, "E")

  #(walls, start, end)
}

fn find_point(grid: List(#(Point, String)), needle: String) -> Point {
  grid
  |> list.map(pair.swap)
  |> list.key_find(needle)
  |> result.unwrap(point.zero())
}

fn heuristic(from: Position, to: Point) -> Int {
  let direction =
    to
    |> point.diff(from.position)
    |> vector.to_unit()

  let dx = int.absolute_value(direction.dx - from.direction.dx)
  let dy = int.absolute_value(direction.dy - from.direction.dy)
  let min_rotates = int.max(dx, dy)

  min_rotates * 1000 + point.manhattan(from.position, to)
}

fn neighbours(walls: Set(Point), current: Position) -> List(#(Position, Int)) {
  let Position(current, direction) = current
  let next = point.add(current, direction)

  let neighbours = case set.contains(walls, next) {
    True -> []
    False -> [#(Position(next, direction), 1)]
  }

  [
    #(Position(current, vector.rotate_ccw(direction)), 1000),
    #(Position(current, vector.rotate_cw(direction)), 1000),
    ..neighbours
  ]
}

fn a_star(
  walls: Set(Point),
  dest: Point,
  queue: priority_queue.Queue(#(Position, Int)),
  lowest_cost: Dict(Position, #(Int, List(Position))),
) -> Dict(Position, #(Int, List(Position))) {
  case priority_queue.pop(queue) {
    Error(_) -> lowest_cost
    Ok(#(#(position, _), queue)) -> {
      let assert Ok(#(cost, _)) = dict.get(lowest_cost, position)

      let to_queue =
        walls
        |> neighbours(position)
        |> list.map(pair.map_second(_, int.add(_, cost)))
        |> list.filter(fn(item) {
          let #(position, cost) = item

          case dict.get(lowest_cost, position) {
            Ok(#(prev_cost, _)) if prev_cost < cost -> False
            _ -> True
          }
        })

      let lowest_cost =
        to_queue
        |> list.fold(lowest_cost, fn(acc, item) {
          let #(next_position, cost) = item

          acc
          |> dict.upsert(next_position, fn(item) {
            case item {
              option.None -> #(cost, [position])
              option.Some(#(prev_cost, _)) if prev_cost > cost -> #(cost, [
                position,
              ])
              option.Some(#(_, prev)) -> #(
                cost,
                [position, ..prev] |> list.unique,
              )
            }
          })
        })

      let queue =
        to_queue
        |> list.map(fn(item) {
          let #(position, cost) = item

          #(position, cost + heuristic(position, dest))
        })
        |> list.fold(queue, fn(queue, item) { priority_queue.push(queue, item) })

      a_star(walls, dest, queue, lowest_cost)
    }
  }
}

fn find_good_spots(
  queue: List(Position),
  costs: Dict(Position, List(Position)),
  found: Set(Position),
) -> Set(Position) {
  case queue {
    [head, ..queue] -> {
      let assert Ok(to_add) = dict.get(costs, head)

      let to_add =
        to_add
        |> list.filter(fn(n) { !set.contains(found, n) })

      queue
      |> list.append(to_add)
      |> find_good_spots(costs, set.insert(found, head))
    }
    [] -> found
  }
}

fn find_costs(
  walls: Set(Point),
  start: Point,
  dest: Point,
) -> Dict(Position, #(Int, List(Position))) {
  let start = Position(start, vector.Vector(1, 0))
  let queue =
    priority_queue.new(fn(a: #(Position, Int), b: #(Position, Int)) {
      int.compare(a.1, b.1)
    })
    |> priority_queue.push(#(start, heuristic(start, dest)))

  walls
  |> a_star(dest, queue, dict.from_list([#(start, #(0, []))]))
}

fn find_end_position(
  costs: Dict(Position, #(Int, List(Position))),
  dest: Point,
) -> #(Position, Int) {
  costs
  |> dict.to_list()
  |> list.filter(fn(item) {
    let #(Position(point, _), _) = item

    point == dest
  })
  |> list_utils.min_by_key(fn(item) {
    let #(_, #(cost, _)) = item
    cost
  })
  |> result.map(pair.map_second(_, pair.first))
  |> result.lazy_unwrap(fn() { panic })
}

fn solve_a(input: Input) -> Int {
  let #(walls, start, dest) = input

  walls
  |> find_costs(start, dest)
  |> find_end_position(dest)
  |> pair.second()
}

fn solve_b(input: Input) -> Int {
  let #(walls, start, dest) = input

  let costs =
    walls
    |> find_costs(start, dest)

  find_end_position(costs, dest)
  |> pair.first()
  |> list.wrap()
  |> find_good_spots(
    costs
      |> dict.map_values(fn(_, item) { item |> pair.second() }),
    set.new(),
  )
  |> set.map(fn(pos) { pos.position })
  |> set.size()
}

pub fn main() {
  helpers.run_solutions(parse, solve_a, solve_b)
}
