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

pub fn zero() -> Vector {
  Vector(0, 0)
}

pub fn rotate_cw(vector: Vector) -> Vector {
  Vector(-vector.dy, vector.dx)
}

pub fn rotate_ccw(vector: Vector) -> Vector {
  Vector(vector.dy, -vector.dx)
}
