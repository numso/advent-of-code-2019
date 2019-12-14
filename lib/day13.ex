defmodule Day13 do
  @doc """
  iex> Day13.part1()
  372
  """
  def part1(), do: run() |> Enum.filter(fn {_, val} -> val == 2 end) |> length

  @doc """
  iex> Day13.part2()
  19297
  """
  def part2(), do: run2()

  def run() do
    program = Parser.int_list("input13.txt", ",")
    pid = spawn(IntCode, :start, [self(), program])
    loop(pid) |> elem(0)
  end

  def run2() do
    [_ | program] = Parser.int_list("input13.txt", ",")
    pid = spawn(IntCode, :start, [self(), [2 | program]])
    spawn(Day13, :controller, [pid])
    loop(pid) |> elem(1)
  end

  def loop(pid, state \\ {%{}, nil}) do
    receive do
      {:output, ^pid, x} ->
        receive do
          {:output, ^pid, y} ->
            receive do
              {:output, ^pid, tile} ->
                {game, score} = update(x, y, tile, state)
                IO.write("\e[H\e[J")
                IO.inspect(score: score)
                draw_screen(game)
                loop(pid, {game, score})
            end
        end

      {:request_input, ^pid} ->
        dir = find_next(state)
        send(pid, {:input, dir})
        loop(pid, state)

      {:finish, ^pid, _} ->
        state
    end
  end

  def find_next({game, _}) do
    [{{ball, _}, _}] = Enum.filter(game, fn {_, val} -> val == 4 end)
    [{{paddle, _}, _}] = Enum.filter(game, fn {_, val} -> val == 3 end)

    case {ball, paddle} do
      {a, a} -> 0
      {a, b} when a < b -> -1
      _ -> 1
    end
  end

  def update(-1, 0, score, {game, _}), do: {game, score}
  def update(x, y, tile, {game, score}), do: {Map.put(game, {x, y}, tile), score}

  def draw_screen(game) do
    for(y <- 0..25, x <- 0..36, do: {x, y})
    |> Enum.map(&Map.get(game, &1))
    |> Enum.map(&tile/1)
    |> Enum.chunk_every(37)
    |> Enum.map(&Enum.join/1)
    |> Enum.map(&IO.inspect(&1))
  end

  def tile(0), do: " "
  def tile(1), do: "|"
  def tile(2), do: "X"
  def tile(3), do: "_"
  def tile(4), do: "o"
  def tile(nil), do: ""

  def controller(pid) do
    case IO.read(2) do
      "a\n" -> send(pid, {:input, -1})
      "o\n" -> send(pid, {:input, 0})
      "e\n" -> send(pid, {:input, 1})
    end

    controller(pid)
  end
end
