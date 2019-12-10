defmodule Day9 do
  @doc """
  iex> Day9.part1()
  3765554916
  """
  def part1(), do: Parser.int_list("input9.txt", ",") |> run(1)

  @doc """
  iex> Day9.part2()
  76642
  """
  def part2(), do: Parser.int_list("input9.txt", ",") |> run(2)

  @doc """
  iex> Day9.run([109,1,204,-1,1001,100,1,100,1008,100,16,101,1006,101,0,99])
  99

  iex> Day9.run([1102,34915192,34915192,7,4,7,99,0])
  1219070632396864

  iex> Day9.run([104,1125899906842624,99])
  1125899906842624
  """
  def run(program, input \\ nil) do
    pid = spawn(IntCode, :start, [self(), program])
    if input, do: send(pid, {:input, input})
    loop(pid)
  end

  def loop(pid) do
    receive do
      {:output, ^pid, _} -> loop(pid)
      {:finish, ^pid, num} -> num
    end
  end
end
