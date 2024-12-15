import gleam/dict
import gleam/int
import gleam/list
import gleam/pair
import gleam/result
import gleam/string
import helpers
import util/grid
import util/list_utils
import util/point
import util/util
import util/vector

type Cell {
  Wall
  Box
  SplitBox(left: Bool)
}

type Move {
  Up
  Down
  Right
  Left
}

type State {
  State(grid: grid.Grid(Cell), pos: point.Point)
}

type Input =
  #(State, List(Move))

fn parse(data: List(String)) -> Input {
  data
  |> list.split_while(fn(line) { !string.is_empty(line) })
  |> pair.map_first(parse_grid)
  |> pair.map_second(parse_moves)
}

fn parse_grid(lines: List(String)) -> State {
  let grid =
    lines
    |> grid.parse_grid()

  let start =
    grid
    |> list.map(pair.swap)
    |> list.key_find("@")
    |> result.unwrap(point.zero())

  let grid =
    grid
    |> list.filter_map(fn(item) {
      let #(point, c) = item

      case c {
        "#" -> Ok(#(point, Wall))
        "O" -> Ok(#(point, Box))
        _ -> Error(Nil)
      }
    })
    |> dict.from_list()

  State(grid, start)
}

fn parse_moves(lines: List(String)) -> List(Move) {
  use line <- list.flat_map(lines)
  use ch <- list.map(string.split(line, ""))

  case ch {
    ">" -> Right
    "<" -> Left
    "^" -> Up
    "v" -> Down
    _ -> panic
  }
}

fn move_point(point: point.Point, move: Move) -> point.Point {
  case move {
    Down -> vector.Vector(0, 1)
    Left -> vector.Vector(-1, 0)
    Right -> vector.Vector(1, 0)
    Up -> vector.Vector(0, -1)
  }
  |> point.add(point, _)
}

fn gps(point: point.Point) -> Int {
  100 * point.y + point.x
}

fn score(state: State) -> Int {
  state.grid
  |> dict.to_list()
  |> list.filter_map(fn(item) {
    case item {
      #(point, Box) -> Ok(gps(point))
      #(point, SplitBox(True)) -> Ok(gps(point))
      _ -> Error(Nil)
    }
  })
  |> int.sum()
}

fn detect_boxes(
  state: State,
  move: Move,
) -> Result(List(#(point.Point, Cell)), Nil) {
  let State(grid, position) = state
  let next = move_point(position, move)

  case dict.get(grid, next) {
    Error(_) -> Ok([])
    Ok(Wall) -> Error(Nil)
    Ok(Box) -> {
      State(grid, next)
      |> detect_boxes(move)
      |> result.map(list.prepend(_, #(next, Box)))
    }
    Ok(SplitBox(left)) -> {
      case move, left {
        Right, True | Left, False -> {
          let next_next = move_point(next, move)
          State(grid, next_next)
          |> detect_boxes(move)
          |> result.map(list.append(_, [
            #(next, SplitBox(left)),
            #(next_next, SplitBox(!left)),
          ]))
        }
        Up, _ | Down, _ -> {
          let other = move_point(next, util.cond(left, Right, Left))

          State(grid, next)
          |> detect_boxes(move)
          |> result.then(fn(l) {
            State(grid, other)
            |> detect_boxes(move)
            |> result.map(list.append(_, l))
          })
          |> result.map(list.append(_, [
            #(next, SplitBox(left)),
            #(other, SplitBox(!left)),
          ]))
        }
        _, _ -> panic
      }
    }
  }
}

fn move(state: State, move: Move) -> State {
  case detect_boxes(state, move) {
    Error(_) -> state
    Ok(to_shift) -> {
      let new_grid =
        state.grid
        |> dict.drop(to_shift |> list.map(pair.first))
        |> dict.merge(
          to_shift
          |> list.map(pair.map_first(_, move_point(_, move)))
          |> dict.from_list(),
        )

      State(new_grid, move_point(state.pos, move))
    }
  }
}

fn solve_a(input: Input) -> Int {
  let #(state, moves) = input

  moves
  |> list.fold(state, move)
  |> score()
}

fn expand(state: State) -> State {
  let State(grid, pos) = state

  let max =
    grid
    |> dict.keys()
    |> list_utils.max(point.compare)
    |> result.unwrap(point.zero())

  let grid =
    {
      use y <- list.map(list.range(0, max.y))
      use offset, x <- list.map_fold(list.range(0, max.x), 0)

      let point = point.Point(x, y)
      let op1 = point.add(point, vector.Vector(offset, 0))
      let op2 = point.add(point, vector.Vector(offset + 1, 0))

      case dict.get(grid, point) {
        Ok(Wall) -> #(offset + 1, [#(op1, Wall), #(op2, Wall)])
        Ok(Box) -> #(offset + 1, [
          #(op1, SplitBox(True)),
          #(op2, SplitBox(False)),
        ])
        _ -> #(offset + 1, [])
      }
    }
    |> list.map(pair.second)
    |> list.flatten()
    |> list.flatten()
    |> dict.from_list()

  let pos = point.add(pos, vector.Vector(pos.x, 0))

  State(grid, pos)
}

fn solve_b(input: Input) -> Int {
  let #(state, moves) = input

  state
  |> expand()
  |> list.fold(moves, _, move)
  |> score()
}

pub fn main() {
  helpers.run_solutions(parse, solve_a, solve_b)
}
