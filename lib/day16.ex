defmodule Day16 do
  @doc """
  iex> Day16.part1()
  "22122816"
  """
  def part1, do: Parser.read("input16.txt") |> run_phases(100) |> String.slice(0, 8)

  @doc """
  iex> Day16.run_phases("12345678", 1)
  "48226158"

  iex> Day16.run_phases("12345678", 2)
  "34040438"

  iex> Day16.run_phases("12345678", 3)
  "03415518"

  iex> Day16.run_phases("12345678", 4)
  "01029498"

  iex> Day16.run_phases("80871224585914546619083218645595", 100) |> String.slice(0, 8)
  "24176176"

  iex> Day16.run_phases("19617804207202209144916044189917", 100) |> String.slice(0, 8)
  "73745418"

  iex> Day16.run_phases("69317163492948606335995924319873", 100) |> String.slice(0, 8)
  "52432133"
  """
  def run_phases(input, times) do
    String.graphemes(input) |> Enum.map(&String.to_integer/1) |> recurse(times) |> Enum.join()
  end

  def recurse(digits, 0), do: digits
  def recurse(digits, times), do: one_phase(digits) |> recurse(times - 1)

  def one_phase(digits) do
    Enum.with_index(digits, 1)
    |> Enum.map(fn {_, i} ->
      [0, 1, 0, -1]
      |> Enum.flat_map(&List.duplicate(&1, i))
      |> Stream.cycle()
      |> Stream.drop(1)
      |> Enum.zip(digits)
      |> Enum.map(fn {j, digit} -> digit * j end)
      |> Enum.sum()
      |> Integer.digits()
      |> List.last()
      |> abs()
    end)
  end
end
