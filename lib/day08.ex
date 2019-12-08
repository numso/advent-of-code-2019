defmodule Day8 do
  @width 25
  @height 6

  @doc """
  iex> Day8.part1()
  1572
  """
  def part1(), do: Parser.int_list("input8.txt", "") |> checksum(@width * @height)

  @doc """
  iex> Day8.part2()
  ["█  █ █   ██  █ ████ ████ ",
   "█ █  █   ██  █ █    █    ",
   "██    █ █ ████ ███  ███  ",
   "█ █    █  █  █ █    █    ",
   "█ █    █  █  █ █    █    ",
   "█  █   █  █  █ █    ████ "]
  """
  def part2(), do: Parser.int_list("input8.txt", "") |> decode(@width * @height) |> render(@width)

  @doc """
  iex> Day8.checksum([0,0,0,0,1,2,0,1,1,2,2,2], 6)
  6
  """
  def checksum(img, length) do
    layer =
      Enum.chunk_every(img, length)
      |> Enum.sort_by(&count(&1, 0))
      |> List.first()

    count(layer, 1) * count(layer, 2)
  end

  defp count(digits, num), do: Enum.count(digits, &(&1 == num))

  @doc """
  iex> Day8.decode([0,2,2,2,1,1,2,2,2,2,1,2,0,0,0,0], 4)
  [0,1,1,0]
  """
  def decode(img, length) do
    Enum.chunk_every(img, length)
    |> Enum.reduce(fn next_layer, cur_layer ->
      Enum.zip(next_layer, cur_layer)
      |> Enum.map(fn {next, cur} -> if cur == 2, do: next, else: cur end)
    end)
  end

  def render(img, width) do
    Enum.chunk_every(img, width)
    |> Enum.map(&(pretty(&1) |> Enum.join()))
    |> IO.inspect()
  end

  defp pretty(line), do: Enum.map(line, &if(&1 == 1, do: "█", else: " "))
end
