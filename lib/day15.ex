defmodule Day15 do
  @doc """
  iex> Day15.part1()
  354
  """
  def part1(), do: build_map() |> shortest_path()

  @doc """
  iex> Day15.part2()
  370
  """
  def part2(), do: build_map() |> longest_path()

  def build_map() do
    program = Parser.int_list("input15.txt", ",")
    map = spawn(IntCode, :start, [self(), program]) |> loop()
    {finish, _} = Enum.find(map, fn {_, val} -> val == 2 end)
    {map, finish}
  end

  def shortest_path({map, finish}), do: shortest_path(map, {0, 0}, finish)

  def shortest_path(map, start, finish, visited \\ MapSet.new(), count \\ 0)
  def shortest_path(_, pos, pos, _, count), do: count

  def shortest_path(map, pos, finish, visited, count) do
    possibilities(map, pos, visited)
    |> Enum.find_value(&shortest_path(map, &1, finish, MapSet.put(visited, pos), count + 1))
  end

  def longest_path({map, finish}), do: longest_path(map, finish) |> Enum.sort() |> List.last()

  def longest_path(map, pos, visited \\ MapSet.new(), count \\ 0) do
    case possibilities(map, pos, visited) do
      [] -> [count]
      next -> Enum.flat_map(next, &longest_path(map, &1, MapSet.put(visited, pos), count + 1))
    end
  end

  def possibilities(map, pos, visited) do
    for(i <- 1..4, {{_, next}, _} = move(i, pos), do: next)
    |> Enum.filter(&(!MapSet.member?(visited, &1)))
    |> Enum.filter(&(Map.get(map, &1) != 0))
  end

  def loop(state \\ %{{0, 0} => 1}, pos \\ {0, 0}, history \\ [], pid) do
    # render(state, pos)

    case next(state, pos, history) do
      {{dir, new_pos}, new_history} ->
        send(pid, {:input, dir})

        receive do
          {:output, ^pid, 0} -> Map.put(state, new_pos, 0) |> loop(pos, history, pid)
          {:output, ^pid, num} -> Map.put(state, new_pos, num) |> loop(new_pos, new_history, pid)
        end

      nil ->
        state
    end
  end

  def next(state, pos, history) do
    case {get_next(state, pos), history} do
      {{next, undo}, history} -> {next, [{undo, pos} | history]}
      {nil, [next | history]} -> {next, history}
      _ -> nil
    end
  end

  def get_next(state, pos) do
    for(x <- 1..4, do: move(x, pos))
    |> Enum.find(fn {{_, pos}, _} -> Map.get(state, pos) == nil end)
  end

  def move(1, {x, y}), do: {{1, {x, y - 1}}, 2}
  def move(2, {x, y}), do: {{2, {x, y + 1}}, 1}
  def move(3, {x, y}), do: {{3, {x - 1, y}}, 4}
  def move(4, {x, y}), do: {{4, {x + 1, y}}, 3}

  def render(state, pos) do
    Process.sleep(10)
    IO.write("\e[H\e[J")
    {x, y, width, height} = Map.keys(state) |> get_dimensions()

    for(y <- y..(y + height), x <- x..(x + width), do: get_tile(state, pos, {x, y}))
    |> Enum.chunk_every(width + 1)
    |> Enum.map(&Enum.join(&1))
    |> Enum.map(&IO.puts(&1))
  end

  def get_dimensions([{x, y}]), do: {x, y, x, y}

  def get_dimensions(keys) do
    [x | sorted_x] = keys |> Enum.map(&elem(&1, 0)) |> Enum.sort()
    [y | sorted_y] = keys |> Enum.map(&elem(&1, 1)) |> Enum.sort()
    {x, y, List.last(sorted_x) - x, List.last(sorted_y) - y}
  end

  def get_tile(_, {x, y}, {x, y}), do: "o"
  def get_tile(_, _, {0, 0}), do: "O"
  def get_tile(state, _, pos), do: Map.get(state, pos) |> get_tile()

  def get_tile(0), do: "█"
  def get_tile(1), do: "."
  def get_tile(2), do: "X"
  def get_tile(_), do: " "
end
