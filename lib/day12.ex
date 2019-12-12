defmodule Day12 do
  @doc """
  iex> Day12.part1()
  12070
  """
  def part1 do
    [
      {-3, 15, -11},
      {3, 13, -19},
      {-13, 18, -2},
      {6, 0, -1}
    ]
    |> prep()
    |> simulate(1000)
    |> energy()
  end

  @doc """
  iex> [{-1, 0, 2}, {2, -10, -7}, {4, -8, 8}, {3, 5, -1}] |> Day12.prep() |> Day12.simulate(10) |> Day12.energy()
  179

  iex> [{-8, -10, 0}, {5, 5, 10}, {2, -7, 3}, {9, -8, -3}] |> Day12.prep() |> Day12.simulate(100) |> Day12.energy()
  1940
  """
  def energy(moons) do
    Enum.map(moons, fn {{x, y, z}, {dx, dy, dz}} ->
      (abs(x) + abs(y) + abs(z)) * (abs(dx) + abs(dy) + abs(dz))
    end)
    |> Enum.sum()
  end

  @doc """
  iex> [{-1, 0, 2}, {2, -10, -7}, {4, -8, 8}, {3, 5, -1}] |> Day12.prep() |> Day12.simulate(10)
  [
    {{2, 1, -3}, {-3, -2, 1}},
    {{1, -8, 0}, {-1, 1, 3}},
    {{3, -6, 1}, {3, 2, -3}},
    {{2, 0, 4}, {1, -1, -1}}
  ]

  iex> [{-8, -10, 0}, {5, 5, 10}, {2, -7, 3}, {9, -8, -3}] |> Day12.prep() |> Day12.simulate(100)
  [
    {{8, -12, -9}, {-7, 3, 0}},
    {{13, 16, -3}, {3, -11, -5}},
    {{-29, -11, -1}, {-3, 7, 4}},
    {{16, -13, 23}, {7, 1, 1}}
  ]
  """
  def simulate(moons, 0), do: moons

  def simulate(moons, iteration) do
    Enum.map(moons, fn {{x, y, z} = pos, vel} ->
      new_vel =
        Enum.reduce(moons, vel, fn {{x1, y1, z1}, _}, {dx, dy, dz} ->
          dx1 = get_modifier(x, x1)
          dy1 = get_modifier(y, y1)
          dz1 = get_modifier(z, z1)
          {dx + dx1, dy + dy1, dz + dz1}
        end)

      {pos, new_vel}
    end)
    |> Enum.map(fn {{x, y, z}, {dx, dy, dz} = vel} -> {{x + dx, y + dy, z + dz}, vel} end)
    |> simulate(iteration - 1)
  end

  def prep(moons), do: Enum.map(moons, &{&1, {0, 0, 0}})

  defp get_modifier(a, b) when a == b, do: 0
  defp get_modifier(a, b) when a < b, do: 1
  defp get_modifier(_, _), do: -1
end
