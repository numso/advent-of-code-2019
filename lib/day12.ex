defmodule Day12 do
  @input [{-3, 15, -11}, {3, 13, -19}, {-13, 18, -2}, {6, 0, -1}]
  def test1, do: [{-1, 0, 2}, {2, -10, -7}, {4, -8, 8}, {3, 5, -1}]
  def test2, do: [{-8, -10, 0}, {5, 5, 10}, {2, -7, 3}, {9, -8, -3}]

  @doc """
  iex> Day12.part1()
  12070
  """
  def part1(), do: simulate_complex(@input, 1000)

  @doc """
  iex> Day12.part2()
  500903629351944
  """
  def part2(), do: find_repeat_complex(@input)

  @doc """
  iex> Day12.simulate_complex(Day12.test1, 10)
  179

  iex> Day12.simulate_complex(Day12.test2, 100)
  1940
  """
  def simulate_complex(moons, count) do
    0..2
    |> Enum.map(&filter_axis(moons, &1))
    |> Enum.map(&simulate(&1, count))
    |> Enum.zip()
    |> Enum.map(fn {{x, dx}, {y, dy}, {z, dz}} -> sum(x, y, z) * sum(dx, dy, dz) end)
    |> Enum.sum()
  end

  def simulate(moons, 0), do: moons
  def simulate(moons, count), do: tick(moons) |> simulate(count - 1)

  defp sum(a, b, c), do: abs(a) + abs(b) + abs(c)

  @doc """
  iex> Day12.find_repeat_complex(Day12.test1)
  2772

  iex> Day12.find_repeat_complex(Day12.test2)
  4686774924
  """
  def find_repeat_complex(moons) do
    0..2
    |> Enum.map(&filter_axis(moons, &1))
    |> Enum.map(&find_repeat/1)
    |> lcm()
  end

  def find_repeat(moons), do: find_repeat(moons, moons, 0)
  def find_repeat(moons, moons, count) when count != 0, do: count
  def find_repeat(moons, start, count), do: tick(moons) |> find_repeat(start, count + 1)

  defp lcm(a, b), do: floor(a * b / Integer.gcd(a, b))
  defp lcm(arr), do: Enum.reduce(arr, &lcm/2)

  defp filter_axis(moons, i), do: Enum.map(moons, &{elem(&1, i), 0})

  def tick(moons) do
    next_vel = fn pos -> Enum.map(moons, &dir(pos, &1)) |> Enum.sum() end

    moons
    |> Enum.map(fn {pos, vel} -> {pos, vel + next_vel.(pos)} end)
    |> Enum.map(fn {pos, vel} -> {pos + vel, vel} end)
  end

  defp dir(a, {b, _}) when a == b, do: 0
  defp dir(a, {b, _}) when a < b, do: 1
  defp dir(_, _), do: -1
end
