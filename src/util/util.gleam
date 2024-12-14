pub fn cond(cond: Bool, then: a, els: a) -> a {
  case cond {
    True -> then
    False -> els
  }
}
