import gleam/int
import gleam/result
import util/int_utils

pub type Vector {
  Vector(dx: Int, dy: Int)
}

pub const orthogonal_directions = [
  Vector(0, 1),
  Vector(1, 0),
  Vector(-1, 0),
  Vector(0, -1),
]

pub fn negate(self: Vector) -> Vector {
  Vector(-self.dx, -self.dy)
}

pub fn add(self: Vector, other: Vector) -> Vector {
  Vector(self.dx + other.dx, self.dy + other.dy)
}

pub fn multiply(self: Vector, with: Int) -> Vector {
  Vector(self.dx * with, self.dy * with)
}

pub fn zero() -> Vector {
  Vector(0, 0)
}

pub fn rotate_cw(vector: Vector) -> Vector {
  Vector(-vector.dy, vector.dx)
}

pub fn rotate_ccw(vector: Vector) -> Vector {
  Vector(vector.dy, -vector.dx)
}

pub fn to_unit(vector: Vector) -> Vector {
  let x =
    vector.dx
    |> int.floor_divide(vector.dx)
    |> result.unwrap(0)
  let y =
    vector.dy
    |> int.floor_divide(vector.dy)
    |> result.unwrap(0)

  Vector(x, y)
}

pub fn normalize(vec: Vector) -> Vector {
  let d = int_utils.gcd(vec.dx, vec.dy)

  Vector(vec.dx / d, vec.dy / d)
}
