import gleam/float
import gleam/int
import gleam/list
import gleam/pair
import gleam/result
import gleam/string
import helpers
import util/int_utils

type Input =
  Computer

fn parse(data: List(String)) -> Input {
  let assert #(registers, [_, program, ..]) = list.split(data, 3)
  let assert [reg_a, reg_b, reg_c] =
    registers
    |> list.map(parse_register)

  let program = program |> parse_program()

  program
  |> new_computer()
  |> update_register(A, reg_a)
  |> update_register(B, reg_b)
  |> update_register(C, reg_c)
}

fn parse_register(line: String) -> Int {
  line
  |> string.drop_start(12)
  |> int_utils.parse_or_zero()
}

fn parse_program(line: String) -> List(Int) {
  line
  |> string.drop_start(9)
  |> string.split(",")
  |> list.map(int_utils.parse_or_zero)
}

type Register {
  A
  B
  C
}

type Computer {
  Computer(
    reg_a: Int,
    reg_b: Int,
    reg_c: Int,
    instruction_pointer: Int,
    program: List(Int),
    output: List(Int),
  )
}

type Step {
  Step(computer: Computer, halt: Bool)
}

fn new_computer(program: List(Int)) -> Computer {
  Computer(
    reg_a: 0,
    reg_b: 0,
    reg_c: 0,
    instruction_pointer: 0,
    program: program,
    output: [],
  )
}

fn update_register(
  computer: Computer,
  register: Register,
  new_value,
) -> Computer {
  case register {
    A -> Computer(..computer, reg_a: new_value)
    B -> Computer(..computer, reg_b: new_value)
    C -> Computer(..computer, reg_c: new_value)
  }
}

fn forward_instruction_pointer(computer: Computer) -> Computer {
  Computer(..computer, instruction_pointer: computer.instruction_pointer + 2)
}

fn combo_op(computer: Computer, op: Int) -> Int {
  case op {
    n if n >= 0 && n <= 3 -> n
    4 -> computer.reg_a
    5 -> computer.reg_b
    6 -> computer.reg_c
    _ -> panic as "Invalid combo operand"
  }
}

fn print(computer: Computer, out: Int) -> Computer {
  Computer(..computer, output: [out, ..computer.output])
}

fn execute(computer: Computer, op_code: Int, operand: Int) {
  case op_code {
    // bxl -> xor
    1 -> {
      let result = int.bitwise_exclusive_or(computer.reg_b, operand)

      computer
      |> update_register(B, result)
      |> forward_instruction_pointer()
    }
    // bst -> modulo
    2 -> {
      let operand = combo_op(computer, operand)
      let result = operand % 8

      computer
      |> update_register(B, result)
      |> forward_instruction_pointer()
    }
    // jnz
    3 -> {
      case computer.reg_a {
        0 -> computer |> forward_instruction_pointer()
        _ -> Computer(..computer, instruction_pointer: operand)
      }
    }
    // bxc -> xor B, C
    4 -> {
      computer.reg_b
      |> int.bitwise_exclusive_or(computer.reg_c)
      |> update_register(computer, B, _)
      |> forward_instruction_pointer()
    }
    // out
    5 -> {
      computer
      |> combo_op(operand)
      |> int.modulo(8)
      |> result.unwrap(0)
      |> print(computer, _)
      |> forward_instruction_pointer()
    }
    // adv, bdv, cdv
    0 | 6 | 7 -> {
      let num = computer.reg_a
      let operand = combo_op(computer, operand)
      let denom =
        int.power(2, int.to_float(operand))
        |> result.unwrap(0.0)
        |> float.truncate()
      let result = int.divide(num, denom) |> result.unwrap(0)

      let target = case op_code {
        0 -> A
        6 -> B
        7 -> C
        _ -> panic
      }

      computer
      |> update_register(target, result)
      |> forward_instruction_pointer()
    }
    _ -> panic as "Invalid opcode"
  }
}

fn step(computer: Computer) -> Step {
  case list.drop(computer.program, computer.instruction_pointer) {
    [op_code, operand, ..] -> execute(computer, op_code, operand) |> Step(False)
    [_] | [] -> Step(computer, True)
  }
}

fn run(computer) -> List(Int) {
  case step(computer) {
    Step(computer, True) -> computer.output |> list.reverse()
    Step(computer, False) -> run(computer)
  }
}

fn solve_a(input: Input) -> String {
  input
  |> run()
  |> list.map(int.to_string)
  |> string.join(",")
}

fn power(a: Int, b: Int) -> Int {
  a
  |> int.power(b |> int.to_float())
  |> result.map(float.truncate)
  |> result.unwrap(0)
}

fn find_quine(computer: Computer, left: Int, acc: Int) -> Result(Int, Nil) {
  case left {
    0 -> Ok(acc)
    _ -> {
      list.range(0, 7)
      |> list.map(fn(m) { acc + m * power(8, left - 1) })
      |> list.map(fn(item) {
        #(item, computer |> update_register(A, item) |> run)
      })
      |> list.filter(fn(item) {
        let #(_, output) = item
        let expected = computer.program |> list.drop(left - 1)
        let output = output |> list.drop(left - 1)
        expected == output
      })
      |> list.map(pair.first)
      |> list.map(find_quine(computer, left - 1, _))
      |> list.reduce(result.or)
      |> result.flatten()
    }
  }
}

fn solve_b(input: Computer) -> Int {
  // Reverse engineering the given program we get this:

  // do {
  // 	b = a % 8
  // 	b = b ⨁ 2
  // 	c = a / pow(2, b)
  // 	b = b ⨁ c ⨁ 3

  // 	print(b % 8)
  // 	a = a / 8	
  // } until(a == 0)

  // So every 3 bits in initial A determine the digits which are output. 

  let n_digits = input.program |> list.length()

  input
  |> find_quine(n_digits, 0)
  |> result.unwrap(0)
}

pub fn main() {
  helpers.run_solutions(parse, solve_a, solve_b)
}
