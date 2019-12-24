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

  @doc """
  iex> Day24.part2(Day24.example, 10)
  99

  iex> Day24.part2()
  ??
  """
  def part2(input \\ @input, minutes \\ 200) do
    parse(input) |> tick(minutes) |> MapSet.size()
  end

  def tick(bugs, 0), do: bugs

  # make sure "level" makes it into the coords
  def tick(bugs, minutes) do
    build_map(fn {x, y} = pos ->
      num_adjacent =
        get_adjacent_positions(x, y)
        |> Enum.count(&MapSet.member?(bugs, &1))

      is_bug = MapSet.member?(bugs, pos)
      num_adjacent == 1 || (num_adjacent == 2 && !is_bug)
    end)
    |> tick(minutes - 1)
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
    # need a part2_build_map that accounts for level. loop from min_level - 1 to max_level + 1
    for(x <- 0..4, y <- 0..4, do: {x, y})
    |> Enum.reduce(MapSet.new(), fn pos, bugs ->
      if fun.(pos), do: MapSet.put(bugs, pos), else: bugs
    end)
  end
end
