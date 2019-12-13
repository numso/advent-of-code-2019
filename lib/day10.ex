defmodule Day10 do
  @doc """
  iex> Day10.part1()
  247
  """
  def part1(), do: Parser.read("input10.txt") |> most_visible() |> elem(0)

  @doc """
  iex> Day10.part2()
  1919
  """
  def part2(), do: Parser.read("input10.txt") |> get_200th()

  @doc """
  iex> Day10Tests.test(0) |> Day10.most_visible()
  Day10Tests.answer(0)

  iex> Day10Tests.test(1) |> Day10.most_visible()
  Day10Tests.answer(1)

  iex> Day10Tests.test(2) |> Day10.most_visible()
  Day10Tests.answer(2)

  iex> Day10Tests.test(3) |> Day10.most_visible()
  Day10Tests.answer(3)

  iex> Day10Tests.test(4) |> Day10.most_visible()
  Day10Tests.answer(4)
  """
  def most_visible(input), do: parse(input) |> find_most_visible()

  def find_most_visible(asteroids) do
    Enum.map(asteroids, &(get_angles(&1, asteroids) |> map_size))
    |> Enum.zip(asteroids)
    |> Enum.sort()
    |> List.last()
  end

  @doc """
  iex> Day10Tests.test(4) |> Day10.get_200th()
  802
  """
  def get_200th(input) do
    asteroids = parse(input)
    {_, pos} = find_most_visible(asteroids)
    {_, {x, y}} = get_angles(pos, asteroids) |> to_list |> Enum.at(199) |> List.first()
    x * 100 + y
  end

  defp to_list(a), do: Enum.to_list(a) |> Enum.sort() |> Enum.reverse() |> Enum.map(&elem(&1, 1))

  defp dist(x, y, x1, y1), do: :math.sqrt(:math.pow(x - x1, 2) + :math.pow(y - y1, 2))

  def get_angles({x, y} = pos, asteroids) do
    (asteroids -- [pos])
    |> Enum.map(fn {x1, y1} -> :math.atan2(x1 - x, y1 - y) + :math.pi() end)
    |> Enum.zip(asteroids)
    |> Enum.sort_by(fn {_, {x1, y1}} -> dist(x, y, x1, y1) end)
    |> Enum.group_by(fn {angle, _} -> angle end)
  end

  def parse(input) do
    String.split(input)
    |> Enum.with_index()
    |> Enum.flat_map(fn {line, y} ->
      String.graphemes(line)
      |> Enum.with_index()
      |> Enum.map(fn
        {"#", x} -> {x, y}
        _ -> nil
      end)
    end)
    |> Enum.filter(& &1)
  end
end

defmodule Day10Tests do
  @external_resource path = Path.join([__DIR__, "inputs", "tests10.txt"])

  data = path |> File.read!() |> String.split("\n\n") |> Enum.with_index()

  for {test, i} <- data do
    [hd | lines] = String.split(test, "\n")
    [count, x, y] = String.split(hd, ", ") |> Enum.map(&String.to_integer/1)

    def test(unquote(i)), do: unquote(Enum.join(lines, "\n"))
    def answer(unquote(i)), do: unquote({count, {x, y}})
  end

  def num_tests(), do: unquote(length(data))
end
