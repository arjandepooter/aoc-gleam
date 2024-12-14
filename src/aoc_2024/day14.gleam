import gleam/dict
import gleam/int
import gleam/list
import gleam/pair
import gleam/result
import gleam/string
import helpers
import util/int_utils
import util/list_utils
import util/pair.{apply_pair, map_both} as _
import util/point.{type Point}
import util/vector.{type Vector}

const width = 101

const height = 103

type Robot {
  Robot(pos: Point, velocity: Vector)
}

type Input =
  List(Robot)

fn parse(data: List(String)) -> Input {
  use line <- list.map(data)

  let assert Ok(#(pos, velocity)) = string.split_once(line, " ")
  let pos = parse_coords(pos, point.Point)
  let velocity = parse_coords(velocity, vector.Vector)

  Robot(pos, velocity)
}

fn parse_coords(s: String, to: fn(Int, Int) -> a) -> a {
  s
  |> string.drop_start(2)
  |> string.split_once(",")
  |> result.unwrap(#("0", "0"))
  |> map_both(int_utils.parse_or_zero)
  |> apply_pair(to)
}

fn wrap(point: Point) -> Point {
  point.Point(
    int.modulo(point.x, width) |> result.unwrap(0),
    int.modulo(point.y, height) |> result.unwrap(0),
  )
}

fn move(robot: Robot, steps: Int) -> Robot {
  let Robot(pos, velocity) = robot

  velocity
  |> vector.multiply(steps)
  |> point.add(pos, _)
  |> wrap()
  |> Robot(robot.velocity)
}

fn step(robots: List(Robot), steps: Int) -> List(Robot) {
  robots
  |> list.map(move(_, steps))
}

fn safety_factor(robots: List(Robot)) -> Int {
  robots
  |> list.filter(fn(robot) {
    robot.pos.x != width / 2 && robot.pos.y != height / 2
  })
  |> list.group(fn(robot) {
    #(robot.pos.x < width / 2, robot.pos.y < height / 2)
  })
  |> dict.values()
  |> list.map(list.length)
  |> list.fold(1, int.multiply)
}

fn solve_a(input: Input) -> Int {
  input
  |> step(100)
  |> safety_factor()
}

fn solve_b(input: Input) -> Int {
  list.range(0, width * height)
  |> list.map(fn(a) { #(a, step(input, a) |> safety_factor) })
  |> list_utils.min_by_key(fn(item) { item.1 })
  |> result.map(pair.first)
  |> result.unwrap(0)
}

pub fn main() {
  helpers.run_solutions(parse, solve_a, solve_b)
}
