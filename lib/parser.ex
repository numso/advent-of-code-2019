defmodule Parser do
  def int_list(filename, separator \\ "\n") do
    Path.join(__DIR__, filename)
    |> File.read!()
    |> String.split(separator)
    |> Enum.map(&String.to_integer/1)
  end
end
