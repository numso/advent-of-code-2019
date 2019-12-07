defmodule Day7 do
  @doc """
  iex> Day7.part1()
  {18812, [2,3,0,4,1]}
  """
  def part1(), do: Parser.int_list("input7.txt", ",") |> simulate()

  @doc """
  iex> Day7.part2()
  {25534964, [6,9,8,7,5]}
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
    determine_all_phases(range)
    |> Enum.reduce({0, nil}, fn phases, {num1, _} = acc ->
      num = simulate_one(program, phases)
      if num < num1, do: acc, else: {num, phases}
    end)
  end

  def simulate_one(program, phases) do
    pids = Enum.map(0..4, fn _ -> spawn(IntCode, :start, [self(), program]) end)
    first = List.first(pids)
    last = List.last(pids)

    pid_map =
      for {pid, i} <- Enum.with_index(pids), into: %{}, do: {pid, Enum.at(pids, i + 1, first)}

    Enum.zip(pids, phases) |> Enum.each(fn {pid, phase} -> send(pid, {:input, phase}) end)
    send(first, {:input, 0})
    loop(pid_map, last)
  end

  def loop(pid_map, last) do
    receive do
      # pipe it into the correct input
      {:output, pid, num} ->
        send(pid_map[pid], {:input, num})
        loop(pid_map, last)

      {:finish, ^last, num} ->
        num
    end
  end

  def determine_all_phases(range) do
    for a <- range,
        b <- range,
        c <- range,
        d <- range,
        e <- range,
        Enum.uniq([a, b, c, d, e]) == [a, b, c, d, e],
        do: [a, b, c, d, e]
  end
end

defmodule IntCode do
  def start(parent, program) do
    Process.put(:parent, parent)
    run(program)
  end

  def run(program, pointer \\ 0) do
    {code, modes} = Enum.at(program, pointer) |> parse()
    {num_inputs, num_outputs} = arg_io_map(code)
    next = pointer + 1 + num_inputs + num_outputs
    out = Enum.at(program, pointer + 1 + num_inputs)

    handle_input = fn ->
      receive do
        {:input, num} -> run(List.replace_at(program, out, num), next)
      end
    end

    handle_output = fn num ->
      Process.put(:result, num)
      Process.get(:parent) |> send({:output, self(), num})
      run(program, next)
    end

    args =
      Enum.slice(program, pointer + 1, num_inputs)
      |> Enum.zip(modes)
      |> Enum.map(fn
        {num, "0"} -> Enum.at(program, num)
        {num, "1"} -> num
      end)

    case instr(code, args) do
      {:write, num} -> run(List.replace_at(program, out, num), next)
      :noop -> run(program, next)
      {:jump, num} -> run(program, num)
      {:output, num} -> handle_output.(num)
      :input -> handle_input.()
      :halt -> Process.get(:parent) |> send({:finish, self(), Process.get(:result)})
    end
  end

  def arg_io_map(instr) when instr in ["01", "02", "07", "08"], do: {2, 1}
  def arg_io_map(instr) when instr in ["05", "06"], do: {2, 0}
  def arg_io_map("04"), do: {1, 0}
  def arg_io_map("03"), do: {0, 1}
  def arg_io_map(_), do: {0, 0}

  def instr("01", [a, b]), do: {:write, a + b}
  def instr("02", [a, b]), do: {:write, a * b}
  def instr("03", _), do: :input
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
