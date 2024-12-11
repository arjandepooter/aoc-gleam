import gleam/int
import gleam/result

pub fn parse_or_zero(s: String) -> Int {
  s
  |> int.parse()
  |> result.unwrap(0)
}
