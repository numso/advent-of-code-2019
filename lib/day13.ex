defmodule Day13 do
  @doc """
  iex> Day13.part1()
  372
  """
  def part1(), do: run() |> elem(0) |> Enum.count(fn {_, val} -> val == 2 end)

  @doc """
  iex> Day13.part2()
  19297
  """
  def part2(), do: run(2) |> elem(1)

  def run(quarters \\ 1) do
    [_ | program] = Parser.int_list("input13.txt", ",")
    spawn(IntCode, :start, [self(), [quarters | program]]) |> loop()
  end

  def loop(pid, state \\ {%{}, nil}) do
    receive do
      {:output, ^pid, x} ->
        receive do
          {:output, ^pid, y} ->
            receive do
              {:output, ^pid, tile} ->
                next_state = update(x, y, tile, state)
                # render_screen(next_state)
                loop(pid, next_state)
            end
        end

      {:request_input, ^pid} ->
        send(pid, {:input, next_input(state)})
        loop(pid, state)

      {:finish, ^pid, _} ->
        state
    end
  end

  def next_input({game, _}) do
    {{ball, _}, _} = Enum.find(game, fn {_, val} -> val == 4 end)
    {{paddle, _}, _} = Enum.find(game, fn {_, val} -> val == 3 end)
    ball - paddle
  end

  def update(-1, 0, score, {game, _}), do: {game, score}
  def update(x, y, tile, {game, score}), do: {Map.put(game, {x, y}, tile), score}

  def render_screen({game, score}) do
    Process.sleep(1)
    IO.write("\e[H\e[J")
    IO.inspect(score: score)

    for(y <- 0..25, x <- 0..36, do: {x, y})
    |> Enum.map(&Map.get(game, &1))
    |> Enum.map(&render_tile/1)
    |> Enum.chunk_every(37)
    |> Enum.map(&Enum.join/1)
    |> Enum.map(&IO.inspect/1)
  end

  def render_tile(0), do: " "
  def render_tile(1), do: "|"
  def render_tile(2), do: "X"
  def render_tile(3), do: "_"
  def render_tile(4), do: "o"
  def render_tile(_), do: ""
end
