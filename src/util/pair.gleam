pub fn map_both(pair: #(a, a), func: fn(a) -> b) -> #(b, b) {
  let #(p1, p2) = pair
  #(func(p1), func(p2))
}

pub fn apply_pair(pair: #(a, b), fun: fn(a, b) -> c) -> c {
  let #(a, b) = pair
  fun(a, b)
}
