import gleam/int
import gleam/list
import gleam/result
import gleam/string
import helpers
import util/int_utils
import util/pair
import util/point.{type Point}
import util/vector.{type Vector}

type Claw {
  Claw(a: Vector, b: Vector, prize: Point)
}

type Input =
  List(Claw)

fn parse(data: List(String)) -> Input {
  use chunk <- list.map(list.sized_chunk(data, 4))

  let assert [button_a, button_b, prize, ..] = chunk

  Claw(parse_button(button_a), parse_button(button_b), parse_prize(prize))
}

fn parse_button(line: String) -> Vector {
  let assert Ok(#(_, line)) = string.split_once(line, ": ")
  let assert Ok(coords) = string.split_once(line, ", ")

  coords
  |> pair.map_both(fn(c) {
    case c {
      "X+" <> x -> x
      "Y+" <> y -> y
      _ -> panic
    }
  })
  |> pair.map_both(int_utils.parse_or_zero)
  |> pair.apply_pair(vector.Vector)
}

fn parse_prize(line: String) -> Point {
  let assert Ok(#(_, line)) = string.split_once(line, ": ")
  let assert Ok(coords) = string.split_once(line, ", ")

  coords
  |> pair.map_both(fn(c) {
    case c {
      "X=" <> x -> x
      "Y=" <> y -> y
      _ -> panic
    }
  })
  |> pair.map_both(int_utils.parse_or_zero)
  |> pair.apply_pair(point.Point)
}

fn diophantine(
  a: Int,
  b: Int,
  c: Int,
) -> Result(#(#(Int, Int), #(Int, Int)), Nil) {
  let #(g, x, y) = int_utils.ext_gcd(a, b)

  case c % g {
    0 -> {
      let scale = int.floor_divide(c, g) |> result.unwrap(0)
      let x = x * scale
      let y = y * scale

      #(#(x, int.floor_divide(-b, g) |> result.unwrap(0)), #(
        y,
        int.floor_divide(a, g) |> result.unwrap(0),
      ))
      |> Ok
    }
    _ -> Error(Nil)
  }
}

fn prize_to_win(claw: Claw) -> Result(Int, Nil) {
  let Claw(vector.Vector(x1, y1), vector.Vector(x2, y2), point.Point(x, y)) =
    claw

  let d1 = diophantine(x1, x2, x)
  let d2 = diophantine(y1, y2, y)
  case d1, d2 {
    Ok(#(#(a1, da1), #(b1, db1))), Ok(#(#(a2, da2), #(b2, db2))) -> {
      let k =
        int.floor_divide(
          db1 * { a2 - a1 } - da1 * { b2 - b1 },
          da1 * db2 - db1 * da2,
        )
        |> result.unwrap(0)
      let a = a2 + da2 * k
      let b = b2 + db2 * k

      case
        vector.Vector(x1, y1)
        |> vector.multiply(a)
        |> vector.add(vector.Vector(x2, y2) |> vector.multiply(b))
      {
        vector.Vector(vx, vy) if vx == x && vy == y -> Ok(3 * a + b)
        _ -> Error(Nil)
      }
    }
    _, _ -> Error(Nil)
  }
}

fn solve_a(input: Input) -> Int {
  input
  |> list.filter_map(prize_to_win)
  |> int.sum()
}

fn solve_b(input: Input) -> Int {
  input
  |> list.map(fn(claw) {
    Claw(
      ..claw,
      prize: claw.prize
        |> point.add(vector.Vector(10_000_000_000_000, 10_000_000_000_000)),
    )
  })
  |> list.filter_map(prize_to_win)
  |> int.sum()
}

pub fn main() {
  helpers.run_solutions(parse, solve_a, solve_b)
}
