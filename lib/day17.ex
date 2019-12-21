defmodule Day17 do
  @doc """
  iex> Day17.part1()
  4044
  """
  def part1(), do: run() |> find_intersections() |> sum()

  @doc """
  iex> Day17.part2()
  893283
  """
  def part2() do
    # TODO:: input = run() |> get_pathway() |> magic_Magic_MAGIC()
    input = "A,B,A,C,A,B,C,B,C,B\nR,8,L,10,L,12,R,4\nR,8,L,12,R,4,R,4\nR,8,L,10,R,8\nn\n"
    run(2, to_charlist(input))
  end

  def run(start, inputs) do
    [_ | program] = Parser.int_list("input17.txt", ",")
    spawn(IntCode, :start, [self(), [start | program]]) |> looper(inputs)
  end

  def looper(pid, inputs) do
    receive do
      {:request_input, ^pid} ->
        [input | next] = inputs
        send(pid, {:input, input})
        looper(pid, next)

      {:finish, ^pid, num} ->
        num
    end
  end

  def run() do
    program = Parser.int_list("input17.txt", ",")
    spawn(IntCode, :start, [self(), program]) |> loop()
  end

  def loop(pid, map \\ []) do
    receive do
      {:output, ^pid, num} ->
        loop(pid, [[num] | map])

      {:finish, ^pid, _} ->
        map |> Enum.reverse() |> Enum.join()
    end
  end

  @doc ~S"""
  iex> Day17.sum(Day17.find_intersections("..#..........\n..#..........\n#######...###\n#.#...#...#.#\n#############\n..#...#...#..\n..#####...^.."))
  76
  """
  def find_intersections(str) do
    map = prep(str)

    filter_where(map, fn pos ->
      [
        at(map, pos),
        at(map, pos, :north),
        at(map, pos, :south),
        at(map, pos, :east),
        at(map, pos, :west)
      ]
      |> Enum.all?(&(&1 == "#"))
    end)
  end

  def sum(coords), do: coords |> Enum.map(fn {x, y} -> x * y end) |> Enum.sum()

  @doc ~S"""
  iex> Day17.get_pathway("#######...#####\n#.....#...#...#\n#.....#...#...#\n......#...#...#\n......#...###.#\n......#.....#.#\n^########...#.#\n......#.#...#.#\n......#########\n........#...#..\n....#########..\n....#...#......\n....#...#......\n....#...#......\n....#####......") |> Enum.join(",")
  "R,8,R,8,R,4,R,4,R,8,L,6,L,2,R,4,R,4,R,8,R,8,R,8,L,6,L,2"
  """
  def get_pathway(str) do
    map = prep(str)
    [{x, y}] = filter_where(map, fn {x, y} -> at(map, {x, y}) == "^" end)
    build_path(:turn, {{x, y}, :north}, map, [])
  end

  def build_path(:turn, {pos, dir}, map, path) do
    cond do
      at(map, pos, left(dir)) == "#" ->
        build_path(:forward, {pos, left(dir)}, map, ["L" | path])

      at(map, pos, right(dir)) == "#" ->
        build_path(:forward, {pos, right(dir)}, map, ["R" | path])

      true ->
        Enum.reverse(path)
    end
  end

  def build_path(:forward, {pos, dir}, map, path) do
    {count, pos} = move_it(map, dir, pos)
    build_path(:turn, {pos, dir}, map, [count | path])
  end

  def move_it(map, dir, pos, count \\ 0) do
    case at(map, pos, dir) do
      "#" -> move_it(map, dir, move(dir, pos), count + 1)
      _ -> {count, pos}
    end
  end

  defp prep(str) do
    String.split(str, "\n", trim: true) |> Enum.map(&String.split(&1, "", trim: true))
  end

  defp at(_, {x, y}) when x < 0 or y < 0, do: nil
  defp at(map, {x, y}), do: map |> Enum.at(y, []) |> Enum.at(x)
  defp at(map, {x, y}, :north), do: at(map, {x, y - 1})
  defp at(map, {x, y}, :south), do: at(map, {x, y + 1})
  defp at(map, {x, y}, :east), do: at(map, {x + 1, y})
  defp at(map, {x, y}, :west), do: at(map, {x - 1, y})

  defp left(dir), do: turn(dir, 0)
  defp right(dir), do: turn(dir, 1)

  def turn(:north, 0), do: :west
  def turn(:east, 0), do: :north
  def turn(:south, 0), do: :east
  def turn(:west, 0), do: :south
  def turn(:north, 1), do: :east
  def turn(:east, 1), do: :south
  def turn(:south, 1), do: :west
  def turn(:west, 1), do: :north

  def move(:north, {x, y}), do: {x, y - 1}
  def move(:east, {x, y}), do: {x + 1, y}
  def move(:south, {x, y}), do: {x, y + 1}
  def move(:west, {x, y}), do: {x - 1, y}

  defp filter_where([row | _] = map, fun) do
    height = length(map)
    width = length(row)
    for(x <- 0..(width - 1), y <- 0..(height - 1), do: {x, y}) |> Enum.filter(fun)
  end
end
