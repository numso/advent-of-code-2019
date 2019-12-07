defmodule Day6 do
  @doc ~S"""
  iex> "COM)B\nB)C\nC)D\nD)E\nE)F\nB)G\nG)H\nD)I\nE)J\nJ)K\nK)L" |> Day6.part1()
  42

  iex> Parser.read("input6.txt") |> Day6.part1()
  621125
  """
  def part1(input), do: parse(input) |> count(0, "COM")

  @doc ~S"""
  iex> "COM)B\nB)C\nC)D\nD)E\nE)F\nB)G\nG)H\nD)I\nE)J\nJ)K\nK)L\nK)YOU\nI)SAN" |> Day6.part2()
  4

  iex> Parser.read("input6.txt") |> Day6.part2()
  550
  """
  def part2(input), do: parse(input) |> find("COM")

  def count(planets, level, key) do
    Enum.filter(planets, fn [planet, _] -> planet == key end)
    |> Enum.map(fn [_, moon] -> count(planets, level + 1, moon) end)
    |> Enum.sum()
    |> Kernel.+(level)
  end

  def find(_, "SAN"), do: {:santa, 0}
  def find(_, "YOU"), do: {:you, -1}

  def find(planets, key) do
    Enum.filter(planets, fn [planet, _] -> planet == key end)
    |> Enum.map(fn [_, moon] -> find(planets, moon) end)
    |> Enum.reduce(nil, fn
      {_, num}, {_, num2} -> num + num2
      {key, num}, _ -> {key, num + 1}
      el, acc -> acc || el
    end)
  end

  def parse(input), do: String.split(input) |> Enum.map(&String.split(&1, ")"))
end
