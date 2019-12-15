defmodule Day14 do
  @doc """
  iex> Day14.part1()
  374457
  """
  def part1(), do: Parser.read("input14.txt") |> get_fuel()

  @doc """
  iex> Day14.part2()
  3568888
  """
  def part2(), do: Parser.read("input14.txt") |> get_max_fuel()

  @doc """
  iex> Day14Tests.test(0) |> Day14.get_max_fuel()
  Day14Tests.answer2(0)

  iex> Day14Tests.test(1) |> Day14.get_max_fuel()
  Day14Tests.answer2(1)

  iex> Day14Tests.test(2) |> Day14.get_max_fuel()
  Day14Tests.answer2(2)

  iex> Day14Tests.test(3) |> Day14.get_max_fuel()
  Day14Tests.answer2(3)

  iex> Day14Tests.test(4) |> Day14.get_max_fuel()
  Day14Tests.answer2(4)
  """
  def get_max_fuel(input) do
    recipes = parse(input)
    fun = fn i -> get_ore_needed(recipes, "FUEL", i) |> elem(0) <= 1_000_000_000_000 end
    binary_search(fun, 0, 1_000_000_000_000)
  end

  def binary_search(_, min, max) when min >= max, do: max

  def binary_search(fun, min, max) do
    num = min + round((max - min) / 2)

    if fun.(num) do
      binary_search(fun, num, max)
    else
      binary_search(fun, min, num - 1)
    end
  end

  @doc """
  iex> Day14Tests.test(0) |> Day14.get_fuel()
  Day14Tests.answer(0)

  iex> Day14Tests.test(1) |> Day14.get_fuel()
  Day14Tests.answer(1)

  iex> Day14Tests.test(2) |> Day14.get_fuel()
  Day14Tests.answer(2)

  iex> Day14Tests.test(3) |> Day14.get_fuel()
  Day14Tests.answer(3)

  iex> Day14Tests.test(4) |> Day14.get_fuel()
  Day14Tests.answer(4)
  """
  def get_fuel(input), do: parse(input) |> get_ore_needed("FUEL", 1) |> elem(0)

  def get_ore_needed(recipes, chemical, amount, inventory \\ %{})
  def get_ore_needed(_, "ORE", amount, inventory), do: {amount, inventory}

  def get_ore_needed(recipes, chemical, amount, inventory) do
    case {Map.get(inventory, chemical, 0), amount} do
      {num_owned, num_needed} when num_owned >= num_needed ->
        {0, Map.put(inventory, chemical, num_owned - num_needed)}

      {num_owned, num_needed} ->
        {amount, reqs} = Map.get(recipes, chemical)
        required_amount = num_needed - num_owned
        num_batches = ceil(required_amount / amount)
        inv = Map.put(inventory, chemical, num_batches * amount - required_amount)

        Enum.reduce(reqs, {0, inv}, fn {count, chemical}, {ore, inv} ->
          {ore2, inv2} = get_ore_needed(recipes, chemical, count * num_batches, inv)
          {ore + ore2, inv2}
        end)
    end
  end

  def parse(input) do
    String.split(input, "\n")
    |> Enum.map(fn line ->
      [raw_reqs, result] = String.split(line, " => ")
      {count, chemical} = parse_chemical(result)
      reqs = String.split(raw_reqs, ", ") |> Enum.map(&parse_chemical(&1))
      {chemical, {count, reqs}}
    end)
    |> Enum.into(%{})
  end

  def parse_chemical(chunk) do
    [count, chemical] = String.split(chunk, " ")
    {String.to_integer(count), chemical}
  end
end

defmodule Day14Tests do
  @external_resource path = Path.join([__DIR__, "inputs", "tests14.txt"])

  data = path |> File.read!() |> String.split("\n\n") |> Enum.with_index()

  for {test, i} <- data do
    [hd | lines] = String.split(test, "\n")
    [one, two] = String.split(hd, ", ")

    def test(unquote(i)), do: unquote(Enum.join(lines, "\n"))
    def answer(unquote(i)), do: unquote(String.to_integer(one))
    def answer2(unquote(i)), do: unquote(String.to_integer(two))
  end

  def num_tests(), do: unquote(length(data))
end
