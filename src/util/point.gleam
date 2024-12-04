import gleam/int
import gleam/order
import util/vector

pub type Point {
  Point(x: Int, y: Int)
}

pub fn zero() -> Point {
  Point(0, 0)
}

pub fn compare(p1: Point, p2: Point) -> order.Order {
  case int.compare(p1.x, p2.x) {
    order.Eq -> int.compare(p1.y, p2.y)
    result -> result
  }
}

pub fn add(self: Point, vec: vector.Vector) -> Point {
  Point(self.x + vec.dx, self.y + vec.dy)
}

pub fn sub(self: Point, vec: vector.Vector) -> Point {
  vec
  |> vector.negate()
  |> add(self, _)
}
