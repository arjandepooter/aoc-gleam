import gleam/dict
import gleam/function
import gleam/int
import gleam/list
import gleam/pair
import gleam/set.{type Set}
import helpers
import util/grid.{type Grid}
import util/point.{type Point}
import util/vector.{type Vector}

type Input =
  Grid(String)

fn parse(data: List(String)) -> Input {
  data
  |> grid.parse_grid()
  |> dict.from_list()
}

fn find_area(
  queue: List(Point),
  grid: Grid(String),
  acc: Set(Point),
) -> Set(Point) {
  case queue {
    [] -> acc
    [cur, ..rest] -> {
      let assert Ok(value) = dict.get(grid, cur)

      rest
      |> list.append(
        cur
        |> grid.filter_neighbours(grid, fn(p, other) {
          other == value && !set.contains(acc, p)
        })
        |> list.map(pair.first),
      )
      |> list.unique()
      |> find_area(grid, set.insert(acc, cur))
    }
  }
}

fn scan(grid: Grid(String)) -> List(Set(Point)) {
  grid
  |> dict.keys()
  |> list.map_fold(set.new(), fn(seen, point) {
    case set.contains(seen, point) {
      True -> {
        #(seen, Error(Nil))
      }
      False -> {
        let area = find_area([point], grid, set.new())
        #(set.union(seen, area), Ok(area))
      }
    }
  })
  |> pair.second()
  |> list.filter_map(function.identity)
}

fn perimeter(area: Set(Point)) -> Int {
  area
  |> set.to_list()
  |> list.map(fn(point) {
    vector.orthogonal_directions
    |> list.map(point.add(point, _))
    |> list.filter(fn(point) { !set.contains(area, point) })
    |> list.length()
  })
  |> int.sum()
}

fn scan_side(
  queue: List(#(Point, Vector)),
  area: Set(Point),
  acc: Set(#(Point, Vector)),
) -> Set(#(Point, Vector)) {
  case queue {
    [] -> acc
    [#(point, dir), ..tail] -> {
      [vector.rotate_cw(dir), vector.rotate_ccw(dir)]
      |> list.map(point.add(point, _))
      |> list.filter(fn(point) {
        set.contains(area, point)
        && !set.contains(area, point.add(point, dir))
        && !set.contains(acc, #(point, dir))
      })
      |> list.map(fn(point) { #(point, dir) })
      |> list.append(tail)
      |> list.unique()
      |> scan_side(area, set.insert(acc, #(point, dir)))
    }
  }
}

fn number_of_sides(area: Set(Point)) -> Int {
  let queue = {
    use point <- list.flat_map(set.to_list(area))
    use direction <- list.filter_map(vector.orthogonal_directions)

    let other = point.add(point, direction)
    case set.contains(area, other) {
      True -> Error(Nil)
      False -> Ok(#(point, direction))
    }
  }

  queue
  |> list.map_fold(set.new(), fn(seen, item) {
    case set.contains(seen, item) {
      True -> #(seen, Error(Nil))
      False -> {
        let side =
          item
          |> list.wrap()
          |> scan_side(area, set.new())

        #(set.union(seen, side), Ok(side))
      }
    }
  })
  |> pair.second()
  |> list.filter_map(function.identity)
  |> list.length()
}

fn solve_a(input: Input) -> Int {
  let areas =
    input
    |> scan()

  areas
  |> list.map(set.size)
  |> list.map2(list.map(areas, perimeter), int.multiply)
  |> int.sum()
}

fn solve_b(input: Input) -> Int {
  let areas =
    input
    |> scan()

  areas
  |> list.map(set.size)
  |> list.map2(list.map(areas, number_of_sides), int.multiply)
  |> int.sum()
}

pub fn main() {
  helpers.run_solutions(parse, solve_a, solve_b)
}
