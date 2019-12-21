defmodule Day19 do
  @doc """
  iex> Day19.part1()
  138
  """
  def part1() do
    program = Parser.int_list("input19.txt", ",")

    for(x <- 0..49, y <- 0..49, do: {x, y})
    |> Enum.map(&run_one(&1, program))
    |> Enum.sum()
  end

  @doc """
  iex> Day19.part2()
  13530764
  """
  def part2() do
    program = Parser.int_list("input19.txt", ",")
    {x, y} = find_coords({5, 3}, program)
    x * 10000 + y
  end

  def run_one({x, y}, program) do
    pid = spawn(IntCode, :start, [self(), program])
    send(pid, {:input, x})
    send(pid, {:input, y})

    receive do
      {:finish, ^pid, num} -> num
    end
  end

  def find_coords({x, y}, program) do
    case run_one({x + 99, y - 99}, program) do
      1 -> {x, y - 99}
      _ -> find_next({x, y + 1}, program) |> find_coords(program)
    end
  end

  def find_next({x, y} = pos, program) do
    case run_one(pos, program) do
      1 -> pos
      _ -> find_next({x + 1, y}, program)
    end
  end
end
