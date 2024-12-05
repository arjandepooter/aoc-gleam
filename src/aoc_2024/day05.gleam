import gleam/dict.{type Dict}
import gleam/int
import gleam/list
import gleam/option.{type Option}
import gleam/order.{type Order}
import gleam/pair
import gleam/result
import gleam/set.{type Set}
import gleam/string
import helpers
import util/pair as my_pair

type Input =
  #(Dict(Int, Set(Int)), List(List(Int)))

fn parse(data: List(String)) -> Input {
  let #(l1, l2) =
    data
    |> list.split_while(fn(line) { !string.is_empty(line) })

  let deps = {
    use line <- list.map(l1)

    line
    |> string.split_once("|")
    |> result.unwrap(#("", ""))
    |> my_pair.map_both(int.parse)
    |> my_pair.map_both(result.unwrap(_, 0))
  }
  let deps =
    deps
    |> list.fold(dict.new(), fn(acc, pair) {
      let #(a, b) = pair

      acc
      |> dict.upsert(a, fn(result) {
        case result {
          option.None -> set.from_list([b])
          option.Some(st) -> set.insert(st, b)
        }
      })
    })

  let updates = {
    use line <- list.map(l2)

    line
    |> string.split(",")
    |> list.map(int.parse)
    |> list.map(result.unwrap(_, 0))
  }

  #(deps, updates)
}

fn is_valid_update(update: List(Int), deps: Dict(Int, Set(Int))) -> Bool {
  update
  |> list.fold(#(set.new(), True), fn(state, page) {
    case state {
      #(_, False) -> state
      #(head, _) ->
        case dict.get(deps, page) {
          Error(_) -> #(set.insert(head, page), True)
          Ok(cmp) ->
            case cmp |> set.intersection(head) |> set.size() {
              0 -> #(set.insert(head, page), True)
              _ -> #(head, False)
            }
        }
    }
  })
  |> pair.second()
}

fn page_compare(deps: Dict(Int, Set(Int))) -> fn(Int, Int) -> Order {
  fn(p1: Int, p2: Int) -> Order {
    let assert [d1, d2] =
      [p1, p2]
      |> list.map(dict.get(deps, _))
      |> list.map(result.unwrap(_, set.new()))

    case set.contains(d1, p2), set.contains(d2, p1) {
      True, False -> order.Lt
      False, True -> order.Gt
      _, _ -> order.Eq
    }
  }
}

fn get_middle_page(update: List(Int)) -> Int {
  update
  |> list.drop(list.length(update) / 2)
  |> list.first()
  |> result.unwrap(0)
}

fn solve_a(input: Input) -> Option(String) {
  let #(deps, updates) = input

  updates
  |> list.filter(is_valid_update(_, deps))
  |> list.map(get_middle_page)
  |> int.sum()
  |> int.to_string()
  |> option.Some
}

fn solve_b(input: Input) -> Option(String) {
  let #(deps, updates) = input
  let cmp = page_compare(deps)

  updates
  |> list.filter(fn(update) { !is_valid_update(update, deps) })
  |> list.map(list.sort(_, cmp))
  |> list.map(get_middle_page)
  |> int.sum()
  |> int.to_string()
  |> option.Some
}

pub fn main() {
  helpers.run_solutions(parse, solve_a, solve_b)
}
