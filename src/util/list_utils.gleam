import gleam/list
import gleam/order

pub fn max(lst: List(a), cmp: fn(a, a) -> order.Order) -> Result(a, Nil) {
  use a, b <- list.reduce(lst)

  case cmp(a, b) {
    order.Lt -> b
    _ -> a
  }
}

pub fn min(lst: List(a), cmp: fn(a, a) -> order.Order) -> Result(a, Nil) {
  use a, b <- list.reduce(lst)

  case cmp(a, b) {
    order.Gt -> b
    _ -> a
  }
}

pub fn max_by_key(lst: List(a), key: fn(a) -> Int) -> Result(a, Nil) {
  case lst {
    [] -> Error(Nil)
    [a] -> Ok(a)
    [a, b, ..rest] ->
      case key(a) >= key(b) {
        True -> max_by_key([a, ..rest], key)
        False -> max_by_key([b, ..rest], key)
      }
  }
}

pub fn min_by_key(lst: List(a), key: fn(a) -> Int) -> Result(a, Nil) {
  max_by_key(lst, fn(n) { key(n) * -1 })
}
