defmodule Day20 do
  @doc """
  iex> Day20.part1("test20-1.txt")
  23

  iex> Day20.part1("test20-2.txt")
  58

  iex> Day20.part1()
  400
  """
  def part1(filename \\ "input20.txt") do
    {start, finish, maze, portals} = Parser.read(filename) |> parse()
    breadth_first([start], finish, maze, portals)
  end

  def breadth_first(positions, finish, maze, portals, visited \\ MapSet.new(), count \\ 0) do
    next_positions =
      Enum.flat_map(positions, fn {x, y} ->
        [{x + 1, y}, {x - 1, y}, {x, y + 1}, {x, y - 1}]
        |> Enum.map(&(Map.get(portals, &1, {&1, nil}) |> elem(0)))
        |> Enum.filter(&(!MapSet.member?(visited, &1)))
        |> Enum.filter(&MapSet.member?(maze, &1))
      end)

    case Enum.find(next_positions, &(&1 == finish)) do
      nil ->
        next_visited = MapSet.new(positions) |> MapSet.union(visited)
        breadth_first(next_positions, finish, maze, portals, next_visited, count + 1)

      _ ->
        count + 1
    end
  end

  @doc """
  iex> Day20.part2("test20-1.txt")
  26

  iex> Day20.part2("test20-3.txt")
  396

  iex> Day20.part2()
  4986
  """
  def part2(filename \\ "input20.txt") do
    {start, finish, maze, portals} = Parser.read(filename) |> parse()
    breadth_first_rec([{0, start}], {0, finish}, maze, portals)
  end

  def breadth_first_rec(positions, finish, maze, portals, visited \\ MapSet.new(), count \\ 0) do
    next_positions =
      Enum.flat_map(positions, fn {l, {x, y}} ->
        [{l, {x + 1, y}}, {l, {x - 1, y}}, {l, {x, y + 1}}, {l, {x, y - 1}}]
        |> Enum.map(fn {l, pos} = loc ->
          case Map.get(portals, pos) do
            {_, -1} when l == 0 -> loc
            {next_pos, dir} -> {l + dir, next_pos}
            _ -> loc
          end
        end)
        |> Enum.filter(&(!MapSet.member?(visited, &1)))
        |> Enum.filter(fn {_, pos} -> MapSet.member?(maze, pos) end)
      end)

    case Enum.find(next_positions, &(&1 == finish)) do
      nil ->
        next_visited = MapSet.new(positions) |> MapSet.union(visited)
        breadth_first_rec(next_positions, finish, maze, portals, next_visited, count + 1)

      _ ->
        count + 1
    end
  end

  def parse(input) do
    [line | _] = raw = String.split(input, "\n") |> Enum.map(&String.graphemes/1)
    width = length(line)
    height = length(raw)
    coords = for x <- 0..(width - 1), y <- 0..(height - 1), do: {x, y}
    maze = Enum.filter(coords, &(at(raw, &1) == ".")) |> MapSet.new()

    portals =
      Enum.reduce(coords, [], fn pos, data ->
        case parse_portal(raw, pos) do
          {"AA", _} -> data
          {"ZZ", _} -> data
          {code, dot_pos} -> [{code, pos, dot_pos} | data]
          nil -> data
        end
      end)
      |> Enum.group_by(fn {code, _, _} -> code end)
      |> Enum.flat_map(fn {_, [{_, a1, a2}, {_, b1, b2}]} -> [{a1, b2}, {b1, a2}] end)
      |> Enum.map(fn {{x, y} = key, val} ->
        dir = if x == 1 || y == 1 || x == width - 2 || y == height - 2, do: -1, else: 1
        {key, {val, dir}}
      end)
      |> Enum.into(%{})

    start =
      Enum.find_value(coords, fn pos ->
        case parse_portal(raw, pos) do
          {"AA", dot_pos} -> dot_pos
          _ -> nil
        end
      end)

    finish =
      Enum.find_value(coords, fn pos ->
        case parse_portal(raw, pos) do
          {"ZZ", dot_pos} -> dot_pos
          _ -> nil
        end
      end)

    {start, finish, maze, portals}
  end

  def parse_portal(raw, {x, y}) do
    case at(raw, {x, y}) do
      char when char in [" ", ".", "#", nil] ->
        nil

      char ->
        north = at(raw, {x, y - 1})
        south = at(raw, {x, y + 1})
        west = at(raw, {x - 1, y})
        east = at(raw, {x + 1, y})

        case {north, south, west, east} do
          {".", char2, _, _} -> {char <> char2, {x, y - 1}}
          {char2, ".", _, _} -> {char2 <> char, {x, y + 1}}
          {_, _, ".", char2} -> {char <> char2, {x - 1, y}}
          {_, _, char2, "."} -> {char2 <> char, {x + 1, y}}
          _ -> nil
        end
    end
  end

  def at(_, {x, y}) when x < 0 or y < 0, do: nil
  def at(list, {x, y}), do: list |> Enum.at(y, []) |> Enum.at(x)
end
