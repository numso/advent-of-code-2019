defmodule Day22 do
  @doc """
  iex> Day22.part1()
  4684
  """
  def part1() do
    {m, o} = Parser.read("input22.txt") |> parse() |> reduce_instructions(10007)
    rem(m * 2019 + o, 10007)
  end

  @doc """
  iex> Day22.part2()
  ??
  """
  def part2() do
    {m, o} = Parser.read("input22.txt") |> parse() |> reduce_instructions(119_315_717_514_047)

    Enum.reduce(1..101_741_582_076_661, 2020, fn i, acc ->
      if acc == 2020, do: IO.puts("YAY: #{i}")
      if rem(i, 100_000_000) == 0, do: IO.puts(i)
      rem(m * acc + o, 119_315_717_514_047)
    end)
  end

  def reduce_instructions(instructions, len) do
    multiplier =
      Enum.map(instructions, fn
        {:inc, num} -> num
        _ -> 1
      end)
      |> Enum.reduce(1, &(&1 * &2))

    {_, offset} =
      Enum.reduce(instructions, {-1, 0}, fn
        {:cut, num}, {sign, total} -> {sign, sign * num + total}
        {:inc, num}, {sign, total} -> {sign, total * num}
        :deal, {sign, total} -> {sign * -1, total + sign * (len - 1)}
      end)

    {multiplier, offset}
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
