defmodule Day23 do
  @doc """
  iex> Day23.part1()
  18513
  """
  def part1(), do: Parser.int_list("input23.txt", ",") |> run()

  def run(program) do
    Enum.map(0..49, fn nic ->
      pid = spawn(IntCode, :start, [self(), program])
      send(pid, {:input, nic})
      pid
    end)
    |> loop()
  end

  def loop(pids) do
    receive do
      {:output, p, 255} ->
        receive do
          {:output, ^p, _} ->
            receive do
              {:output, ^p, y} -> y
            end
        end

      {:output, p, dest} ->
        receive do
          {:output, ^p, x} ->
            receive do
              {:output, ^p, y} ->
                pid = Enum.at(pids, dest)
                send(pid, {:input, x})
                send(pid, {:input, y})
                loop(pids)
            end
        end
    end
  end

  @doc """
  iex> Day23.part2()
  13286
  """
  def part2(), do: Parser.int_list("input23.txt", ",") |> run2()

  def run2(program) do
    Enum.map(0..49, fn nic ->
      pid = spawn(IntCode, :start, [self(), program])
      send(pid, {:input, nic})
      pid
    end)
    |> loop2({-1, -1})
  end

  def loop2(pids, {x, y} = saved) do
    receive do
      {:output, p, 255} ->
        receive do
          {:output, ^p, x} ->
            receive do
              {:output, ^p, ^y} -> y
              {:output, ^p, y} -> loop2(pids, {x, y})
            end
        end

      {:output, p, dest} ->
        receive do
          {:output, ^p, x} ->
            receive do
              {:output, ^p, y} ->
                pid = Enum.at(pids, dest)
                send(pid, {:input, x})
                send(pid, {:input, y})
                loop2(pids, saved)
            end
        end
    after
      10 ->
        pid = List.first(pids)
        send(pid, {:input, x})
        send(pid, {:input, y})
        loop2(pids, saved)
    end
  end
end
