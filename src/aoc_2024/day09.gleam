import gleam/int
import gleam/list
import gleam/option.{type Option}
import gleam/pair
import gleam/result
import gleam/string
import helpers

type Input =
  List(Int)

fn parse(data: List(String)) -> Input {
  use line <- list.flat_map(data)

  line
  |> string.split("")
  |> list.map(int.parse)
  |> list.map(result.unwrap(_, 0))
}

fn to_pairs(lst: List(Int)) -> List(#(Int, Int)) {
  lst
  |> list.sized_chunk(2)
  |> list.map(fn(chunk) {
    case chunk {
      [a, b] -> #(a, b)
      [a] -> #(a, 0)
      _ -> panic
    }
  })
}

type Block {
  Block(size: Int, gap: Int, id: Int)
}

fn to_blocks(lst: List(Int)) -> List(Block) {
  lst
  |> to_pairs()
  |> list.index_map(fn(item, id) {
    let #(size, gap) = item

    Block(size, gap, id)
  })
}

fn to_gapped_list(lst: List(#(Int, Int))) -> List(Option(Int)) {
  use acc, item, idx <- list.index_fold(lst, [])
  let #(size, gap) = item

  idx
  |> option.Some()
  |> list.repeat(size)
  |> list.append(list.repeat(option.None, gap))
  |> list.append(acc, _)
}

fn densen_rec(
  lst: List(Option(Int)),
  rev: List(Option(Int)),
  acc: List(Int),
) -> List(Int) {
  case lst, rev {
    [], _ -> acc
    [option.Some(a), ..lst], _ -> densen_rec(lst, rev, [a, ..acc])
    [option.None, ..lst], [option.Some(b), ..rev] ->
      densen_rec(lst, rev, [b, ..acc])
    [option.None, ..], [option.None, ..rev] -> densen_rec(lst, rev, acc)
    _, _ -> panic
  }
}

fn densen(lst: List(Option(Int))) -> List(Int) {
  let length =
    lst
    |> list.filter(option.is_some)
    |> list.length()
  let rev = list.reverse(lst)

  lst
  |> densen_rec(rev, [])
  |> list.reverse()
  |> list.take(length)
}

fn defrag(lst: List(Block)) -> List(Block) {
  let ids =
    lst
    |> list.reverse()
    |> list.map(fn(block) { block.id })

  use acc, id <- list.fold(ids, lst)

  let assert #(head, [cur_block, ..tail]) =
    acc
    |> list.split_while(fn(block) { block.id != id })

  let result =
    head
    |> list.map_fold(False, fn(found, block) {
      case found, block {
        False, Block(id: _, size: _, gap: gap) if gap >= cur_block.size -> {
          let new_block = Block(..cur_block, gap: gap - cur_block.size)
          let prev_block = Block(..block, gap: 0)

          #(True, [prev_block, new_block])
        }
        _, _ -> #(found, [block])
      }
    })

  case result {
    #(True, result) -> {
      result
      |> list.flatten()
      |> list.append([
        Block(..cur_block, size: 0, gap: cur_block.size + cur_block.gap),
        ..tail
      ])
    }
    #(False, _) -> acc
  }
}

fn checksum(lst: List(Int)) -> Int {
  lst
  |> list.index_map(int.multiply)
  |> int.sum()
}

fn block_checksum(lst: List(Block)) -> Int {
  lst
  |> list.map_fold(0, fn(idx, block) {
    let offset = idx + block.gap + block.size
    let block_sum =
      block.size
      |> int.multiply(block.size - 1)
      |> int.divide(2)
      |> result.unwrap(0)
      |> int.add(idx * block.size)
      |> int.multiply(block.id)

    #(offset, block_sum)
  })
  |> pair.second()
  |> int.sum()
}

fn solve_a(input: Input) -> Int {
  input
  |> to_pairs()
  |> to_gapped_list()
  |> densen()
  |> checksum()
}

fn solve_b(input: Input) -> Int {
  input
  |> to_blocks()
  |> defrag()
  |> block_checksum()
}

pub fn main() {
  helpers.run_solutions(parse, solve_a, solve_b)
}
