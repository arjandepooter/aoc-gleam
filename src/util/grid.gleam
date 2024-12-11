import gleam/dict.{type Dict}
import gleam/list
import gleam/result
import gleam/string
import util/point.{type Point}
import util/vector

pub type Grid(a) =
  Dict(Point, a)

pub fn parse_grid(data: List(String)) -> List(#(point.Point, String)) {
  {
    use line, y <- list.index_map(data)
    use char, x: Int <- list.index_map(string.split(line, ""))

    #(point.Point(x, y), char)
  }
  |> list.flatten()
}

pub fn filter_neighbours(
  point: Point,
  grid: Grid(a),
  with: fn(Point, a) -> Bool,
) -> List(#(Point, a)) {
  use direction <- list.filter_map([
    vector.Vector(1, 0),
    vector.Vector(0, 1),
    vector.Vector(-1, 0),
    vector.Vector(0, -1),
  ])

  let next_point =
    point
    |> point.add(direction)

  next_point
  |> dict.get(grid, _)
  |> result.try(fn(a) {
    case with(next_point, a) {
      True -> Ok(#(next_point, a))
      False -> Error(Nil)
    }
  })
}
