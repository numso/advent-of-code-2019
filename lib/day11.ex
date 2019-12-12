defmodule Day11 do
  @doc """
  iex> Day11.part1()
  2226
  """
  def part1(), do: run(0) |> map_size()

  @doc """
  iex> Day11.part2()
  [" █  █ ███   ██  █    ████ █  █ █    ████   ",
   " █  █ █  █ █  █ █       █ █ █  █    █      ",
   " ████ ███  █    █      █  ██   █    ███    ",
   " █  █ █  █ █ ██ █     █   █ █  █    █      ",
   " █  █ █  █ █  █ █    █    █ █  █    █      ",
   " █  █ ███   ███ ████ ████ █  █ ████ █      "]
  """
  def part2() do
    panels = run(1)
    {x, y, width, height} = get_dimensions(panels)

    for(y <- y..(y + height), x <- (x + width)..x, do: get_tile(Map.get(panels, {x, y})))
    |> Enum.chunk_every(width + 1)
    |> Enum.map(&Enum.join(&1))
  end

  def get_dimensions(panels) do
    [x | sorted_x] = Map.keys(panels) |> Enum.map(&elem(&1, 0)) |> Enum.sort()
    [y | sorted_y] = Map.keys(panels) |> Enum.map(&elem(&1, 1)) |> Enum.sort()
    {x, y, List.last(sorted_x) - x, List.last(sorted_y) - y}
  end

  def get_tile(1), do: "█"
  def get_tile(_), do: " "

  def run(input) do
    program = Parser.int_list("input11.txt", ",")
    pid = spawn(IntCode, :start, [self(), program])
    send(pid, {:input, input})
    loop(pid)
  end

  def loop(pid, panels \\ %{}, pos \\ {0, 0}, facing \\ :north) do
    receive do
      {:output, ^pid, color} ->
        panels = Map.put(panels, pos, color)

        receive do
          {:output, ^pid, direction} ->
            facing = turn(facing, direction)
            pos = move(facing, pos)
            send(pid, {:input, Map.get(panels, pos, 0)})
            loop(pid, panels, pos, facing)
        end

      {:finish, ^pid, _} ->
        panels
    end
  end

  def turn(:north, 0), do: :west
  def turn(:east, 0), do: :north
  def turn(:south, 0), do: :east
  def turn(:west, 0), do: :south
  def turn(:north, 1), do: :east
  def turn(:east, 1), do: :south
  def turn(:south, 1), do: :west
  def turn(:west, 1), do: :north

  def move(:north, {x, y}), do: {x, y - 1}
  def move(:east, {x, y}), do: {x - 1, y}
  def move(:south, {x, y}), do: {x, y + 1}
  def move(:west, {x, y}), do: {x + 1, y}
end
