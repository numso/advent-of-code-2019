defmodule Day1 do
  @doc """
  iex> Day1.part1()
  3454026
  """
  def part1() do
    Parser.int_list("input1.txt") |> Enum.map(&get_fuel/1) |> Enum.sum()
  end

  @doc """
  iex> Day1.part2()
  5178170
  """
  def part2() do
    Parser.int_list("input1.txt") |> Enum.map(&get_more_fuel/1) |> Enum.sum()
  end

  @doc """
  iex> Day1.get_fuel(12)
  2

  iex> Day1.get_fuel(14)
  2

  iex> Day1.get_fuel(1969)
  654

  iex> Day1.get_fuel(100756)
  33583

  """
  def get_fuel(mass), do: Integer.floor_div(mass, 3) - 2

  @doc """
  iex> Day1.get_more_fuel(14)
  2

  iex> Day1.get_more_fuel(1969)
  966

  iex> Day1.get_more_fuel(100756)
  50346
  """
  def get_more_fuel(mass) do
    fuel = get_fuel(mass)
    if fuel <= 0, do: 0, else: fuel + get_more_fuel(fuel)
  end
end
