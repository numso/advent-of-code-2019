defmodule Day14 do
  @doc """
  iex> Day14.part1()
  0
  """
  def part1(), do: Parser.read("input14.txt") |> get_fuel()

  @doc """
  iex> Day14Tests.test(0) |> Day14.get_fuel()
  Day14Test.answer(0)

  iex> Day14Tests.test(1) |> Day14.get_fuel()
  Day14Test.answer(1)

  iex> Day14Tests.test(2) |> Day14.get_fuel()
  Day14Test.answer(2)

  iex> Day14Tests.test(3) |> Day14.get_fuel()
  Day14Test.answer(3)

  iex> Day14Tests.test(4) |> Day14.get_fuel()
  Day14Test.answer(4)
  """
  def get_fuel(input) do
    pairs = parse(input)
    get_reqs("FUEL", 1, pairs) |> Map.get("ORE")
  end

  def get_reqs("ORE", count, _), do: %{"ORE" => count}

  def get_reqs(chemical, count, pairs) do
    {amount, reqs} = Map.get(pairs, chemical)
    multiplier = ceil(count / amount)

    Enum.reduce(reqs, %{}, fn {count, chemical}, acc ->
      next = get_reqs(chemical, count * multiplier, pairs)

      Enum.reduce(next, acc, fn {chemical, amount}, acc ->
        Map.update(acc, chemical, amount, &(&1 + amount))
      end)
    end)
    |> IO.inspect()
  end

  def parse(input) do
    parse_chemical = fn chunk ->
      [count, chemical] = String.split(chunk, " ")
      {String.to_integer(count), chemical}
    end

    String.split(input, "\n")
    |> Enum.map(fn line ->
      [raw_reqs, result] = String.split(line, " => ")
      {count, chemical} = parse_chemical.(result)
      reqs = String.split(raw_reqs, ", ") |> Enum.map(&parse_chemical.(&1))
      {chemical, {count, reqs}}
    end)
    |> Enum.into(%{})
  end
end

defmodule Day14Tests do
  @external_resource path = Path.join([__DIR__, "inputs", "tests14.txt"])

  data = path |> File.read!() |> String.split("\n\n") |> Enum.with_index()

  for {test, i} <- data do
    [hd | lines] = String.split(test, "\n")

    def test(unquote(i)), do: unquote(Enum.join(lines, "\n"))
    def answer(unquote(i)), do: unquote(String.to_integer(hd))
  end

  def num_tests(), do: unquote(length(data))
end
