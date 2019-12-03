defmodule Day2 do
  @doc """
  iex> Day2.part1()
  4945026
  """
  def part1(a \\ 12, b \\ 2) do
    [hd, _, _ | tl] = Parser.int_list("input2.txt", ",")
    [hd, a, b | tl] |> run_program() |> List.first()
  end

  @doc """
  iex> Day2.part2()
  {52, 96}
  """
  def part2() do
    for(x <- 0..99, y <- 0..99, do: {x, y})
    |> Enum.find(fn {x, y} -> part1(x, y) === 19_690_720 end)
  end

  @doc """
  iex> Day2.run_program([1, 0, 0, 0, 99])
  [2, 0, 0, 0, 99]

  iex> Day2.run_program([2, 3, 0, 3, 99])
  [2, 3, 0, 6, 99]

  iex> Day2.run_program([2, 4, 4, 5, 99, 0])
  [2, 4, 4, 5, 99, 9801]

  iex> Day2.run_program([1, 1, 1, 4, 99, 5, 6, 0, 99])
  [30, 1, 1, 4, 2, 5, 6, 0, 99]
  """
  def run_program(program, pointer \\ 0) do
    run = fn count, fun ->
      Enum.slice(program, pointer + 1, count)
      |> Enum.map(&{&1, Enum.at(program, &1)})
      |> fun.()
      |> run_program(pointer + 1 + count)
    end

    case Enum.at(program, pointer) do
      1 -> run.(3, fn [{_, a}, {_, b}, {c, _}] -> List.replace_at(program, c, a + b) end)
      2 -> run.(3, fn [{_, a}, {_, b}, {c, _}] -> List.replace_at(program, c, a * b) end)
      99 -> program
    end
  end
end
