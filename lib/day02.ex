defmodule Day2 do
  @doc """
  iex> Day2.part1()
  4945026
  """
  def part1(a \\ 12, b \\ 2) do
    [hd, _, _ | tl] = Parser.int_list("input2.txt", ",")
    [hd, a, b | tl] |> run() |> List.first()
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
  iex> Day2.run([1, 0, 0, 0, 99])
  [2, 0, 0, 0, 99]

  iex> Day2.run([2, 3, 0, 3, 99])
  [2, 3, 0, 6, 99]

  iex> Day2.run([2, 4, 4, 5, 99, 0])
  [2, 4, 4, 5, 99, 9801]

  iex> Day2.run([1, 1, 1, 4, 99, 5, 6, 0, 99])
  [30, 1, 1, 4, 2, 5, 6, 0, 99]
  """
  def run(program) do
    pid = spawn(IntCode, :start, [self(), program])

    receive do
      {:finish_program, ^pid, program} -> program
    end
  end
end
