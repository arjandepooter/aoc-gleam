import gleam/int
import gleam/list
import gleam/pair
import gleam/result
import gleam/string
import gleam/yielder
import helpers

type Input =
  List(Int)

fn parse(data: List(String)) -> Input {
  data
  |> list.flat_map(fn(s) {
    s
    |> string.split(" ")
    |> list.map(fn(s) {
      s
      |> string.trim()
      |> int.parse()
      |> result.unwrap(0)
    })
  })
}

type Node {
  Node(children: List(Node), metadata: List(Int))
}

fn parse_tree(input: List(Int)) -> #(Int, Node) {
  let assert [n_children, n_metadata, ..rest] = input

  let #(consumed, child_nodes) =
    yielder.repeat(Nil)
    |> yielder.take(n_children)
    |> yielder.fold(#(0, []), fn(acc: #(Int, List(Node)), _) {
      let #(offset, nodes) = acc
      let #(consumed, child_node) =
        parse_tree(
          rest
          |> list.drop(offset),
        )

      #(offset + consumed, list.append(nodes, [child_node]))
    })

  let metadata =
    rest
    |> list.drop(consumed)
    |> list.take(n_metadata)

  #(2 + consumed + n_metadata, Node(child_nodes, metadata))
}

fn walk_tree(node: Node) -> yielder.Yielder(Node) {
  use <- yielder.yield(node)

  node.children
  |> yielder.from_list()
  |> yielder.map(walk_tree)
  |> yielder.flatten()
}

fn node_value(node: Node) -> Int {
  case node {
    Node([], metadata) -> metadata |> int.sum()
    Node(children, metadata) -> {
      metadata
      |> list.map(fn(idx) {
        children
        |> list.drop(idx - 1)
        |> list.first()
        |> result.map(node_value)
        |> result.unwrap(0)
      })
      |> int.sum()
    }
  }
}

fn solve_a(input: Input) -> Int {
  input
  |> parse_tree()
  |> pair.second()
  |> walk_tree()
  |> yielder.flat_map(fn(node) {
    node.metadata
    |> yielder.from_list()
  })
  |> yielder.reduce(int.add)
  |> result.unwrap(0)
}

fn solve_b(input: Input) -> Int {
  input
  |> parse_tree()
  |> pair.second()
  |> node_value()
}

pub fn main() {
  helpers.run_solutions(parse, solve_a, solve_b)
}
