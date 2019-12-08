defmodule Parser do
  def read(filename) do
    Path.join(__DIR__, filename)
    |> File.read!()
  end

  def int_list(filename, separator \\ "\n") do
    read(filename)
    |> String.split(separator, trim: true)
    |> Enum.map(&String.to_integer/1)
  end
end
