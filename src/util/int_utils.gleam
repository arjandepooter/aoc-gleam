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
