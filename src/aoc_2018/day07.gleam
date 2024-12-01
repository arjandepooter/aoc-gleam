import gleam/dict
import gleam/int
import gleam/list
import gleam/option
import gleam/result
import gleam/set
import gleam/string
import helpers

type Input {
  Input(
    dependencies: dict.Dict(String, set.Set(String)),
    nodes: set.Set(String),
  )
}

fn parse_line(line: String) -> option.Option(#(String, String)) {
  case string.split(line, " ") {
    [
      "Step",
      first,
      "must",
      "be",
      "finished",
      "before",
      "step",
      second,
      "can",
      "begin.",
    ] -> option.Some(#(first, second))
    _ -> option.None
  }
}

fn parse(data: List(String)) -> Input {
  let dependencies =
    data
    |> list.map(fn(str) {
      str
      |> string.trim()
      |> parse_line()
    })
    |> list.fold(dict.new(), fn(acc, items) {
      case items {
        option.Some(items) -> {
          let #(first, second) = items
          dict.upsert(acc, second, fn(opt) {
            case opt {
              option.None -> set.from_list([first])
              option.Some(lst) -> set.union(lst, set.from_list([first]))
            }
          })
        }
        _ -> acc
      }
    })

  let nodes =
    dependencies
    |> dict.keys()
    |> set.from_list()
    |> set.union(
      dependencies
      |> dict.values()
      |> list.reduce(set.union)
      |> result.unwrap(set.new()),
    )

  Input(dependencies, nodes)
}

fn find_path(found: List(String), input: Input) -> List(String) {
  let Input(dependencies, nodes) = input
  let found_set = found |> set.from_list()

  let candidate =
    nodes
    |> set.difference(found_set)
    |> set.filter(fn(node) {
      dependencies
      |> dict.get(node)
      |> result.unwrap(set.new())
      |> set.difference(found_set)
      |> set.is_empty()
    })
    |> set.to_list()
    |> list.sort(string.compare)
    |> list.first()

  case candidate {
    Ok(node) ->
      found
      |> list.append([node])
      |> find_path(input)
    _ -> found
  }
}

type State {
  State(work: dict.Dict(String, Int), t: Int, workers: Int)
}

fn new_state() -> State {
  State(dict.new(), 0, 5)
}

fn forward(state: State) -> State {
  let min_t =
    state.work
    |> dict.values()
    |> list.filter(fn(t) { t > 0 })
    |> list.reduce(int.min)
    |> result.unwrap(0)

  let new_work =
    state.work
    |> dict.map_values(fn(_key, value) {
      case value {
        0 -> 0
        t -> t - min_t
      }
    })

  State(..state, t: state.t + min_t, work: new_work)
}

fn add_work(state: State, node: String) -> State {
  let working_time =
    node
    |> string.to_utf_codepoints()
    |> list.first()
    |> result.map(string.utf_codepoint_to_int)
    |> result.unwrap(0)

  State(
    ..state,
    work: {
      state.work
      |> dict.insert(node, working_time - 64 + 60)
    },
  )
}

fn find_time(state: State, input: Input) -> Int {
  let Input(dependencies, nodes) = input
  let in_progress =
    state.work
    |> dict.filter(fn(_key, val) { val > 0 })
  let found_set =
    state.work
    |> dict.filter(fn(_key, val) { val == 0 })
    |> dict.keys()
    |> set.from_list()

  let candidates =
    nodes
    |> set.difference(state.work |> dict.keys() |> set.from_list())
    |> set.filter(fn(node) {
      dependencies
      |> dict.get(node)
      |> result.unwrap(set.new())
      |> set.difference(found_set)
      |> set.is_empty()
    })
    |> set.to_list()
    |> list.sort(string.compare)

  case
    dict.size(in_progress),
    candidates,
    // available workers
    state.workers - dict.size(in_progress)
  {
    0, [], _ -> state.t
    _, _, 0 | _, [], _ -> {
      state
      |> forward()
      |> find_time(input)
    }
    _, [node, ..], _ -> {
      state
      |> add_work(node)
      |> find_time(input)
    }
  }
}

fn solve_a(input: Input) -> option.Option(String) {
  input
  |> find_path([], _)
  |> string.concat()
  |> option.Some()
}

fn solve_b(input: Input) -> option.Option(String) {
  new_state()
  |> find_time(input)
  |> int.to_string()
  |> option.Some()
}

pub fn main() {
  helpers.run_solutions(parse, solve_a, solve_b)
}
