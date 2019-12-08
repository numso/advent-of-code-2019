defmodule Day5 do
  @doc """
  iex> Day5.part1()
  10987514
  """
  def part1(), do: Parser.int_list("input5.txt", ",") |> run(1)

  @doc """
  iex> Day5.part2()
  14195011
  """
  def part2(), do: Parser.int_list("input5.txt", ",") |> run(5)

  def run(program, input) do
    pid = spawn(IntCode, :start, [self(), program])
    send(pid, {:input, input})

    receive do
      {:finish, ^pid, num} -> num
    end
  end
end
