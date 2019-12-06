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
    Process.put(:input, input)
    run({program, 0, nil})
  end

  def run({program, pointer, output}) do
    {code, modes} = Enum.at(program, pointer) |> parse()
    {num_inputs, num_outputs} = arg_io_map(code)
    next = pointer + 1 + num_inputs + num_outputs
    out = Enum.at(program, pointer + 1 + num_inputs)

    args =
      Enum.slice(program, pointer + 1, num_inputs)
      |> Enum.zip(modes)
      |> Enum.map(fn
        {num, "0"} -> Enum.at(program, num)
        {num, "1"} -> num
      end)

    case instr(code, args) do
      {:write, num} -> run({List.replace_at(program, out, num), next, output})
      :noop -> run({program, next, output})
      {:jump, num} -> run({program, num, output})
      {:output, num} -> run({program, next, IO.inspect(num)})
      :halt -> output
    end
  end

  def arg_io_map(instr) when instr in ["01", "02", "07", "08"], do: {2, 1}
  def arg_io_map(instr) when instr in ["05", "06"], do: {2, 0}
  def arg_io_map("04"), do: {1, 0}
  def arg_io_map("03"), do: {0, 1}
  def arg_io_map(_), do: {0, 0}

  def instr("01", [a, b]), do: {:write, a + b}
  def instr("02", [a, b]), do: {:write, a * b}
  def instr("03", _), do: {:write, Process.get(:input)}
  def instr("04", [a]), do: {:output, a}
  def instr("05", [0, _]), do: :noop
  def instr("05", [_, b]), do: {:jump, b}
  def instr("06", [0, b]), do: {:jump, b}
  def instr("06", _), do: :noop
  def instr("07", [a, b]) when a < b, do: {:write, 1}
  def instr("07", _), do: {:write, 0}
  def instr("08", [a, a]), do: {:write, 1}
  def instr("08", _), do: {:write, 0}
  def instr("99", _), do: :halt
  def instr(code), do: raise("Unknown Intcode #{code}")

  def parse(num) do
    [b, a | modes] =
      Integer.to_string(num)
      |> String.pad_leading(5, "0")
      |> String.graphemes()
      |> Enum.reverse()

    {a <> b, modes}
  end
end
