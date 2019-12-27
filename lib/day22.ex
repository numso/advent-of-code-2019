defmodule Day22 do
  @doc """
  iex> Day22.part1()
  4684
  """
  def part1(length \\ 10_007) do
    Parser.read("input22.txt")
    |> parse(length)
    |> Enum.reduce(&combine(&1, &2, length))
    |> do_math(2019, length)
  end

  @doc """
  iex> Day22.part2()
  452290953297
  """
  def part2(length \\ 119_315_717_514_047, num_shuffles \\ 101_741_582_076_661) do
    Parser.read("input22.txt")
    |> parse(length)
    |> Enum.map(&invert(&1, length))
    |> Enum.reduce(&combine(&2, &1, length))
    |> exponent_square_crap(num_shuffles, length)
    |> do_math(2020, length)
  end

  def exponent_square_crap(nums, num_shuffles, length) do
    squared_nums = Stream.iterate(nums, &combine(&1, &1, length))

    num_shuffles
    |> Integer.to_charlist(2)
    |> Enum.reverse()
    |> Enum.zip(squared_nums)
    |> Enum.reject(fn {num, _} -> num == ?0 end)
    |> Enum.map(&elem(&1, 1))
    |> Enum.reduce(&combine(&1, &2, length))
  end

  def invert({m, o}, length), do: {clean_div(1, m, length), clean_div(-o, m, length)}
  def combine({m2, o2}, {m, o}, length), do: {rem(m * m2, length), rem(o * m2 + o2, length)}
  def do_math({m, o}, num, length), do: rem(m * num + o, length)
  def clean_div(a, b, length) when rem(a, b) == 0, do: rem(div(a, b), length)
  def clean_div(a, b, length), do: clean_div(a + length, b, length)

  def parse(input, length) do
    String.split(input, "\n", trim: true)
    |> Enum.map(fn
      "deal into new stack" -> {-1, length - 1}
      "deal with increment " <> num -> {String.to_integer(num), 0}
      "cut " <> num -> {1, -String.to_integer(num)}
    end)
  end
end
