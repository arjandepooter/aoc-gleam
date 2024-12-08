import gleam/int
import gleam/list
import gleam/option
import gleam/pair
import gleam/regexp
import gleam/result
import helpers

type Instruction {
  Mul(Int, Int)
  Do
  Dont
}

type Input =
  List(Instruction)

fn parse(data: List(String)) -> Input {
  let assert Ok(regex) =
    regexp.from_string("(mul\\((\\d+),(\\d+)\\))|(do\\(\\))|(don't\\(\\))")

  {
    use line <- list.flat_map(data)

    regex
    |> regexp.scan(line)
    |> list.map(fn(match) {
      case match {
        regexp.Match("do()", _) -> Do
        regexp.Match("don't()", _) -> Dont
        regexp.Match("mul" <> _, lst) -> {
          let assert [_, option.Some(a), option.Some(b), ..] = lst

          Mul(
            a |> int.parse() |> result.unwrap(0),
            b |> int.parse() |> result.unwrap(0),
          )
        }
        _ -> panic
      }
    })
  }
}

fn solve_a(input: Input) -> Int {
  input
  |> list.map(fn(instruction) {
    case instruction {
      Mul(a, b) -> a * b
      _ -> 0
    }
  })
  |> int.sum()
}

fn solve_b(input: Input) -> Int {
  input
  |> list.fold(#(True, 0), fn(acc, instruction) {
    case acc, instruction {
      #(_, sum), Do -> #(True, sum)
      #(_, sum), Dont -> #(False, sum)
      #(True, sum), Mul(a, b) -> #(True, sum + a * b)
      state, _ -> state
    }
  })
  |> pair.second()
}

pub fn main() {
  helpers.run_solutions(parse, solve_a, solve_b)
}
