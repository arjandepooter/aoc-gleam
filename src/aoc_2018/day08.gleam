import gleam/int
import gleam/iterator
import gleam/list
import gleam/option.{type Option}
import gleam/pair
import gleam/result
import gleam/string
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
    iterator.repeat(Nil)
    |> iterator.take(n_children)
    |> iterator.fold(#(0, []), fn(acc: #(Int, List(Node)), _) {
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

fn walk_tree(node: Node) -> iterator.Iterator(Node) {
  use <- iterator.yield(node)

  node.children
  |> iterator.from_list()
  |> iterator.map(walk_tree)
  |> iterator.flatten()
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

fn solve_a(input: Input) -> Option(String) {
  input
  |> parse_tree()
  |> pair.second()
  |> walk_tree()
  |> iterator.flat_map(fn(node) {
    node.metadata
    |> iterator.from_list()
  })
  |> iterator.reduce(int.add)
  |> result.map(int.to_string)
  |> option.from_result()
}

fn solve_b(input: Input) -> Option(String) {
  input
  |> parse_tree()
  |> pair.second()
  |> node_value()
  |> int.to_string()
  |> option.Some()
}

pub fn main() {
  helpers.run_solutions(parse, solve_a, solve_b)
}
