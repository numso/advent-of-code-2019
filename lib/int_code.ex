defmodule IntCode do
  def start(parent, program), do: run(parent, from_list(program), 0, 0)

  def run(pid, program, pointer, rpointer) do
    {code, modes} = Map.get(program, pointer, 0) |> parse()
    {num_args, num_in} = arg_io_map(code)
    next = pointer + 1 + num_args

    {inputs, outputs} =
      Enum.take(0..num_args, num_args)
      |> Enum.zip(modes)
      |> Enum.map(fn {i, mode} -> {i < num_in, mode, Map.get(program, pointer + 1 + i, 0)} end)
      |> Enum.map(fn
        {true, "0", num} -> Map.get(program, num, 0)
        {true, "1", num} -> num
        {true, "2", num} -> Map.get(program, rpointer + num, 0)
        {false, "0", num} -> num
        {false, "2", num} -> rpointer + num
      end)
      |> Enum.split(num_in)

    case instr(code, inputs) do
      {:write, num} ->
        run(pid, Map.put(program, List.first(outputs), num), next, rpointer)

      :noop ->
        run(pid, program, next, rpointer)

      {:jump, num} ->
        run(pid, program, num, rpointer)

      {:jumpr, num} ->
        run(pid, program, next, rpointer + num)

      {:output, num} ->
        Process.put(:result, num)
        send(pid, {:output, self(), num})
        run(pid, program, next, rpointer)

      :input ->
        send(pid, {:request_input, self()})

        receive do
          {:input, num} -> run(pid, Map.put(program, List.first(outputs), num), next, rpointer)
        end

      :halt ->
        send(pid, {:finish, self(), Process.get(:result)})
        send(pid, {:finish_program, self(), to_list(program)})
    end
  end

  def arg_io_map(instr) when instr in ["01", "02", "07", "08"], do: {3, 2}
  def arg_io_map(instr) when instr in ["05", "06"], do: {2, 2}
  def arg_io_map(instr) when instr in ["04", "09"], do: {1, 1}
  def arg_io_map("03"), do: {1, 0}
  def arg_io_map("99"), do: {0, 0}
  def arg_io_map(code), do: raise("Unknown Intcode #{code} in arg_io_map/1")

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
  def instr("09", [a]), do: {:jumpr, a}
  def instr("99", _), do: :halt
  def instr(code), do: raise("Unknown Intcode #{code} in instr/2")

  def parse(num) do
    Integer.to_string(num)
    |> String.pad_leading(5, "0")
    |> String.graphemes()
    |> Enum.reverse()
    |> (fn [b, a | modes] -> {a <> b, modes} end).()
  end

  defp from_list(list), do: Enum.with_index(list) |> Enum.into(%{}, fn {c, i} -> {i, c} end)
  defp to_list(obj), do: Enum.map(0..(map_size(obj) - 1), &Map.get(obj, &1))
end
