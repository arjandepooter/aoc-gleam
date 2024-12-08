import gleam/list
import gleam/string
import util/point

pub fn parse_grid(data: List(String)) -> List(#(point.Point, String)) {
  {
    use line, y <- list.index_map(data)
    use char, x: Int <- list.index_map(string.split(line, ""))

    #(point.Point(x, y), char)
  }
  |> list.flatten()
}
