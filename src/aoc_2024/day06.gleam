import gleam/dict.{type Dict}
import gleam/int
import gleam/list
import gleam/option.{type Option}
import gleam/pair
import gleam/result
import gleam/set.{type Set}
import gleam/string
import helpers
import util/point.{type Point}
import util/vector.{type Vector}

type Input {
  Input(grid: Dict(Point, Bool), start: Point, direction: Vector)
}

fn parse(data: List(String)) -> Input {
  let points =
    {
      use line, y <- list.index_map(data)
      use char, x <- list.index_map(string.split(line, ""))

      #(point.Point(x, y), char)
    }
    |> list.flatten

  let grid =
    points
    |> list.map(pair.map_second(_, fn(char) {
      case char {
        "#" -> True
        _ -> False
      }
    }))
    |> dict.from_list

  let #(start, direction) =
    {
      use pair <- list.find_map(points)
      let #(point, char) = pair

      case char {
        ">" -> Ok(#(point, vector.Vector(1, 0)))
        "<" -> Ok(#(point, vector.Vector(-1, 0)))
        "^" -> Ok(#(point, vector.Vector(0, -1)))
        "v" -> Ok(#(point, vector.Vector(0, 1)))
        _ -> Error(Nil)
      }
    }
    |> result.lazy_unwrap(fn() { panic })

  Input(grid, start, direction)
}

fn turn(vec: Vector) -> Vector {
  let vector.Vector(x, y) = vec

  vector.Vector(-y, x)
}

type Path {
  Finite(Set(#(Point, Vector)))
  Infinite(Set(#(Point, Vector)))
}

fn new_path() -> Path {
  Finite(set.new())
}

fn path_points(path: Path) -> Set(Point) {
  case path {
    Finite(points) | Infinite(points) ->
      points
      |> set.map(pair.first)
  }
}

fn is_infinite(path: Path) -> Bool {
  case path {
    Infinite(_) -> True
    Finite(_) -> False
  }
}

fn find_path(
  grid: Dict(Point, Bool),
  pos: Point,
  dir: Vector,
  acc: Path,
) -> Path {
  let next = point.add(pos, dir)
  let assert Finite(acc) = acc
  case set.contains(acc, #(pos, dir)), dict.get(grid, next) {
    True, _ -> Infinite(acc)
    _, Ok(True) -> find_path(grid, pos, turn(dir), acc |> Finite)
    _, Ok(False) ->
      find_path(grid, next, dir, set.insert(acc, #(pos, dir)) |> Finite)
    _, Error(_) -> set.insert(acc, #(pos, dir)) |> Finite
  }
}

fn solve_a(input: Input) -> Option(String) {
  let Input(grid, pos, dir) = input

  grid
  |> find_path(pos, dir, new_path())
  |> path_points()
  |> set.size()
  |> int.to_string()
  |> option.Some
}

fn solve_b(input: Input) -> Option(String) {
  let Input(grid, pos, dir) = input

  let points =
    grid
    |> find_path(pos, dir, new_path())
    |> path_points()
    |> set.to_list()
    |> list.filter(fn(point) { point != pos })

  points
  |> list.filter(fn(point) {
    grid
    |> dict.insert(point, True)
    |> find_path(pos, dir, new_path())
    |> is_infinite
  })
  |> list.length
  |> int.to_string
  |> option.Some
}

pub fn main() {
  helpers.run_solutions(parse, solve_a, solve_b)
}
