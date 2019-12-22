defmodule Day21 do
  @doc """
  iex> Day21.part1()
  19351230
  """
  def part1() do
    # (!C AND D) OR !A
    [
      "NOT C J",
      "AND D J",
      "NOT A T",
      "OR T J",
      "WALK",
      ""
    ]
    |> run()
  end

  @doc """
  iex> Day21.part2()
  1141262756
  """
  def part2() do
    # ((!B OR !C) AND D AND (E OR H)) OR !A
    [
      "NOT B J",
      "NOT C T",
      "OR T J",
      "AND D J",
      "NOT E T",
      "NOT T T",
      "OR H T",
      "AND T J",
      "NOT A T",
      "OR T J",
      "RUN",
      ""
    ]
    |> run()
  end

  def run(inputs) do
    program = Parser.int_list("input21.txt", ",")
    pid = spawn(IntCode, :start, [self(), program])

    inputs
    |> Enum.join("\n")
    |> to_charlist()
    |> Enum.each(fn char ->
      send(pid, {:input, char})
    end)

    case loop(pid) |> Enum.drop(33) do
      [[result]] -> result
      map -> map |> Enum.join() |> IO.puts()
    end
  end

  def loop(pid, map \\ []) do
    receive do
      {:output, ^pid, num} -> loop(pid, [[num] | map])
      {:finish, ^pid, _} -> map |> Enum.reverse()
    end
  end
end
