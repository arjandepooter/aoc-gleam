import gleam/dynamic
import gleam/float
import gleam/int
import gleam/result
import gleam_community/maths/elementary

pub fn parse_or_zero(s: String) -> Int {
  s
  |> int.parse()
  |> result.unwrap(0)
}

pub fn number_of_digits(n: Int) -> Int {
  n
  |> int.to_float()
  |> elementary.logarithm_10()
  |> result.unwrap(1.0)
  |> float.truncate()
  |> int.add(1)
}

pub fn gcd(a: Int, b: Int) -> Int {
  case b {
    0 -> a
    _ -> gcd(b, a % b)
  }
}

pub fn lcm(a: Int, b: Int) -> Int {
  a * b / gcd(a, b)
}

pub fn ext_gcd(a: Int, b: Int) -> #(Int, Int, Int) {
  case b {
    0 -> #(a, 1, 0)
    _ -> {
      let #(g, x1, y1) = ext_gcd(b, a % b)
      let x = y1
      let y = x1 - { a / b } * y1
      #(g, x, y)
    }
  }
}
