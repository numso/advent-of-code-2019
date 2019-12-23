defmodule Day22 do
  @doc """
  iex> Day22.part1()
  4684
  """
  def part1(), do: Parser.read("input22.txt") |> deal(10007) |> Enum.find_index(&(&1 == 2019))

  @doc ~S"""
  iex> Day22.deal("deal with increment 7\ndeal into new stack\ndeal into new stack", 10)
  [0, 3, 6, 9, 2, 5, 8, 1, 4, 7]

  iex> Day22.deal("cut 6\ndeal with increment 7\ndeal into new stack", 10)
  [3, 0, 7, 4, 1, 8, 5, 2, 9, 6]

  iex> Day22.deal("deal with increment 7\ndeal with increment 9\ncut -2", 10)
  [6, 3, 0, 7, 4, 1, 8, 5, 2, 9]

  iex> Day22.deal("deal into new stack\ncut -2\ndeal with increment 7\ncut 8\ncut -4\ndeal with increment 7\ncut 3\ndeal with increment 9\ndeal with increment 3\ncut -1", 10)
  [9, 2, 5, 8, 1, 4, 7, 0, 3, 6]
  """
  def deal(input, len) do
    range = 0..(len - 1)

    parse(input)
    |> Enum.reduce(range, fn
      :deal, cards ->
        Enum.reverse(cards)

      {:cut, num}, cards ->
        {first, last} = Enum.split(cards, num)
        last ++ first

      {:inc, num}, cards ->
        Enum.reduce(cards, {0, []}, fn card, {i, cards} ->
          {rem(i + num, len), [{i, card} | cards]}
        end)
        |> elem(1)
        |> Enum.sort()
        |> Enum.map(fn {_, card} -> card end)
    end)
  end

  def parse(input) do
    String.split(input, "\n", trim: true)
    |> Enum.map(fn
      "deal into new stack" -> :deal
      "deal with increment " <> num -> {:inc, String.to_integer(num)}
      "cut " <> num -> {:cut, String.to_integer(num)}
    end)
  end
end
