defmodule Day24 do
  def example,
    do: """
    ....#
    #..#.
    #..##
    ..#..
    #....
    """

  @input """
  #.#..
  .#.#.
  #...#
  .#..#
  ##.#.
  """

  @doc """
  iex> Day24.part1(Day24.example)
  2129920

  iex> Day24.part1()
  25719471
  """
  def part1(input \\ @input) do
    parse(input) |> find_dup(MapSet.new()) |> bio_rating()
  end

  def find_dup(bugs, cache) do
    new_bugs =
      build_map(fn {x, y} = pos ->
        num_adjacent =
          [{x - 1, y}, {x + 1, y}, {x, y - 1}, {x, y + 1}]
          |> Enum.count(&MapSet.member?(bugs, &1))

        is_bug = MapSet.member?(bugs, pos)
        num_adjacent == 1 || (num_adjacent == 2 && !is_bug)
      end)

    if MapSet.member?(cache, new_bugs) do
      new_bugs
    else
      find_dup(new_bugs, MapSet.put(cache, new_bugs))
    end
  end

  def bio_rating(bugs) do
    MapSet.to_list(bugs)
    |> Enum.map(fn {x, y} -> :math.pow(2, y * 5 + x) |> trunc() end)
    |> Enum.sum()
  end

  def parse(input) do
    raw = String.split(input) |> Enum.map(&String.graphemes/1)
    build_map(fn {x, y} -> raw |> Enum.at(y, []) |> Enum.at(x) == "#" end)
  end

  defp build_map(fun) do
    for(x <- 0..4, y <- 0..4, do: {x, y})
    |> Enum.reduce(MapSet.new(), fn pos, bugs ->
      if fun.(pos), do: MapSet.put(bugs, pos), else: bugs
    end)
  end

  @doc """
  iex> Day24.part2(Day24.example, 10)
  99

  iex> Day24.part2()
  1916
  """
  def part2(input \\ @input, minutes \\ 200) do
    parse(input) |> add_levels() |> tick(minutes) |> MapSet.size()
  end

  def add_levels(positions), do: Enum.map(positions, fn {x, y} -> {0, x, y} end) |> MapSet.new()

  def tick(bugs, 0), do: bugs

  def tick(bugs, minutes) do
    sorted = Enum.sort(bugs)
    {min, _, _} = List.first(sorted)
    {max, _, _} = List.last(sorted)

    build_map_2((min - 1)..(max + 1), fn
      {_, 2, 2} ->
        false

      {l, x, y} = pos ->
        num_adjacent =
          get_adjacent_positions(l, x, y)
          |> Enum.count(&MapSet.member?(bugs, &1))

        is_bug = MapSet.member?(bugs, pos)
        num_adjacent == 1 || (num_adjacent == 2 && !is_bug)
    end)
    |> tick(minutes - 1)
  end

  def get_adjacent_positions(l, x, y) do
    [{l, x - 1, y}, {l, x + 1, y}, {l, x, y - 1}, {l, x, y + 1}]
    |> Enum.flat_map(fn
      {l, 2, 2} ->
        case {x, y} do
          {1, _} -> for a <- 0..4, do: {l + 1, 0, a}
          {3, _} -> for a <- 0..4, do: {l + 1, 4, a}
          {_, 1} -> for a <- 0..4, do: {l + 1, a, 0}
          {_, 3} -> for a <- 0..4, do: {l + 1, a, 4}
        end

      {l, -1, _} ->
        [{l - 1, 1, 2}]

      {l, 5, _} ->
        [{l - 1, 3, 2}]

      {l, _, -1} ->
        [{l - 1, 2, 1}]

      {l, _, 5} ->
        [{l - 1, 2, 3}]

      pos ->
        [pos]
    end)
  end

  defp build_map_2(levels, fun) do
    for(l <- levels, x <- 0..4, y <- 0..4, do: {l, x, y})
    |> Enum.reduce(MapSet.new(), fn pos, bugs ->
      if fun.(pos), do: MapSet.put(bugs, pos), else: bugs
    end)
  end
end
