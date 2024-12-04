pub type Vector {
  Vector(dx: Int, dy: Int)
}

pub fn negate(self: Vector) -> Vector {
  Vector(-self.dx, -self.dy)
}

pub fn zero() -> Vector {
  Vector(0, 0)
}
