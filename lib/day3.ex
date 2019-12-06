defmodule Day3 do
  @doc ~S"""
  iex> Day3.part1()
  731
  """
  def part1(), do: Parser.read("input3.txt") |> parse() |> find_closest()

  @doc ~S"""
  iex> Day3.part2()
  5672
  """
  def part2(), do: Parser.read("input3.txt") |> parse() |> find_shortest()

  @doc ~S"""
  iex> "R8,U5,L5,D3\nU7,R6,D4,L4" |> Day3.parse() |> Day3.find_closest()
  6

  iex> "R75,D30,R83,U83,L12,D49,R71,U7,L72\nU62,R66,U55,R34,D71,R55,D58,R83" |> Day3.parse() |> Day3.find_closest()
  159

  iex> "R98,U47,R26,D63,R33,U87,L62,D20,R33,U53,R51\nU98,R91,D20,R16,D67,R40,U7,R15,U6,R7" |> Day3.parse() |> Day3.find_closest()
  135
  """
  def find_closest(wires) do
    get_intersections(wires)
    |> Enum.map(fn {x, y} -> abs(x) + abs(y) end)
    |> Enum.sort()
    |> List.first()
  end

  @doc ~S"""
  iex> "R8,U5,L5,D3\nU7,R6,D4,L4" |> Day3.parse() |> Day3.find_shortest()
  30

  iex> "R75,D30,R83,U83,L12,D49,R71,U7,L72\nU62,R66,U55,R34,D71,R55,D58,R83" |> Day3.parse() |> Day3.find_shortest()
  610

  iex> "R98,U47,R26,D63,R33,U87,L62,D20,R33,U53,R51\nU98,R91,D20,R16,D67,R40,U7,R15,U6,R7" |> Day3.parse() |> Day3.find_shortest()
  410
  """
  def find_shortest([wire1, wire2] = wires) do
    get_intersections(wires)
    |> Enum.map(&(get_length(wire1, &1) + get_length(wire2, &1)))
    |> Enum.sort()
    |> List.first()
  end

  def get_intersections([wire1, wire2]) do
    MapSet.intersection(build_set(wire1), build_set(wire2))
    |> MapSet.delete({0, 0})
  end

  def build_set(set \\ MapSet.new(), pos \\ {0, 0}, wire)
  def build_set(set, _, []), do: set

  def build_set(set, {x, y}, [{dx, dy} | tl]) do
    for(x <- x..(x + dx), y <- y..(y + dy), do: {x, y})
    |> Enum.reduce(set, &MapSet.put(&2, &1))
    |> build_set({x + dx, y + dy}, tl)
  end

  def get_length([hd | tl], {x1, y1} = desired, {x, y} \\ {0, 0}, count \\ 0) do
    case hd do
      {0, dy} when x1 === x and y1 in y..(y + dy) -> count + abs(y - y1)
      {dx, 0} when y1 === y and x1 in x..(x + dx) -> count + abs(x - x1)
      {dx, dy} -> get_length(tl, desired, {x + dx, y + dy}, count + abs(dx) + abs(dy))
    end
  end

  def parse(text) do
    String.split(text)
    |> Enum.map(fn line ->
      String.split(line, ",")
      |> Enum.map(fn
        "L" <> num -> {-String.to_integer(num), 0}
        "R" <> num -> {String.to_integer(num), 0}
        "U" <> num -> {0, -String.to_integer(num)}
        "D" <> num -> {0, String.to_integer(num)}
      end)
    end)
  end
end
