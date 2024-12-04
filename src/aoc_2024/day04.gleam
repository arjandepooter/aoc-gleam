import gleam/dict.{type Dict}
import gleam/function
import gleam/int
import gleam/io
import gleam/list
import gleam/option.{type Option}
import gleam/result
import gleam/string
import helpers
import util/point.{type Point, Point}
import util/vector.{type Vector, Vector}

type Input =
  Dict(Point, String)

fn parse(data: List(String)) -> Input {
  {
    use line, y <- list.index_map(data)
    use char, x <- list.index_map(line |> string.trim() |> string.split(""))

    #(Point(x, y), char)
  }
  |> list.flatten()
  |> dict.from_list()
}

fn find_word(
  pos: Point,
  grid: Dict(Point, String),
  dir: vector.Vector,
  word: String,
) -> Bool {
  case string.split(word, "") {
    [c, ..rest] ->
      case dict.get(grid, pos) {
        Error(_) -> False
        Ok(char) ->
          case char == c {
            True ->
              find_word(point.add(pos, dir), grid, dir, string.join(rest, ""))
            False -> False
          }
      }
    _ -> True
  }
}

fn solve_a(input: Input) -> Option(String) {
  let directions =
    {
      use dx <- list.flat_map(list.range(-1, 1))
      use dy <- list.map(list.range(-1, 1))

      Vector(dx, dy)
    }
    |> list.filter(fn(dir) { dir != vector.zero() })
  let points =
    input
    |> dict.keys()

  {
    use pos <- list.flat_map(points)
    use dir <- list.map(directions)

    find_word(pos, input, dir, "XMAS")
  }
  |> list.count(function.identity)
  |> int.to_string()
  |> option.Some
}

fn is_x_mas(pos: Point, grid: Dict(Point, String)) -> Bool {
  case dict.get(grid, pos) {
    Error(_) -> False
    Ok(char) ->
      case char {
        "A" -> {
          [Vector(1, 1), Vector(1, -1), Vector(-1, -1), Vector(-1, 1)]
          |> list.map(fn(dir) { pos |> point.add(dir) |> dict.get(grid, _) })
          |> list.map(result.unwrap(_, ""))
          |> string.join("")
          |> list.repeat(4)
          |> list.zip(["MMSS", "MSSM", "SSMM", "SMMS"])
          |> list.any(fn(pair) {
            let #(a, b) = pair
            a == b
          })
        }
        _ -> False
      }
  }
}

fn solve_b(input: Input) -> Option(String) {
  input
  |> dict.keys()
  |> list.count(is_x_mas(_, input))
  |> int.to_string()
  |> option.Some
}

pub fn main() {
  helpers.run_solutions(parse, solve_a, solve_b)
}
