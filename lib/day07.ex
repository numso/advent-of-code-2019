defmodule Day7 do
  @doc """
  iex> Day7.part1() |> elem(0)
  18812
  """
  def part1(), do: Parser.int_list("input7.txt", ",") |> simulate()

  @doc """
  iex> Day7.part2() |> elem(0)
  25534964
  """
  def part2(), do: Parser.int_list("input7.txt", ",") |> simulate(5..9)

  @doc """
  iex> [3,15,3,16,1002,16,10,16,1,16,15,15,4,15,99,0,0] |> Day7.simulate()
  {43210, [4,3,2,1,0]}

  iex> [3,23,3,24,1002,24,10,24,1002,23,-1,23,101,5,23,23,1,24,23,23,4,23,99,0,0] |> Day7.simulate()
  {54321, [0,1,2,3,4]}

  iex> [3,31,3,32,1002,32,10,32,1001,31,-2,31,1007,31,0,33,1002,33,7,33,1,33,31,31,1,32,31,31,4,31,99,0,0,0] |> Day7.simulate()
  {65210, [1,0,4,3,2]}
  """
  def simulate(program, range \\ 0..4) do
    cartesian_uniq(range)
    |> Enum.map(&{simulate_one(program, &1), &1})
    |> Enum.sort()
    |> List.last()
  end

  def simulate_one(program, phases) do
    pids = Enum.map(phases, fn _ -> spawn(IntCode, :start, [self(), program]) end)
    [first | rest] = pids
    pid_map = Enum.zip(pids, rest ++ [first]) |> Enum.into(%{})
    Enum.zip(pids, phases) |> Enum.each(fn {pid, phase} -> send(pid, {:input, phase}) end)
    send(first, {:input, 0})
    loop(pid_map, List.last(pids))
  end

  def loop(pid_map, last) do
    receive do
      {:output, pid, num} ->
        send(pid_map[pid], {:input, num})
        loop(pid_map, last)

      {:finish, ^last, num} ->
        num
    end
  end

  defp cartesian_uniq(range), do: cartesian_uniq(Enum.to_list(range), [])
  defp cartesian_uniq([], phase), do: [Enum.reverse(phase)]

  defp cartesian_uniq(input, output) do
    Enum.flat_map(input, &cartesian_uniq(input -- [&1], [&1 | output]))
  end
end
