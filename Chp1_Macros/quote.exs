defmodule Test do 

  IO.puts "quote do: :atom -> #{inspect quote do: :atom}"
  IO.puts "quote do: 123 -> #{inspect quote do: 123}"
  IO.puts "quote do: 3.14 -> #{inspect quote do: 3.14}"
  IO.puts "quote do: [1,2,3] -> #{inspect quote do: [1,2,3]}"
  IO.puts "quote do: \"string\" -> #{inspect quote do: "string"}"
  IO.puts "quote do: {:ok, 1} -> #{inspect quote do: {:ok, 1}}"
  IO.puts "quote do: {:ok, [1,2,3]} -> #{inspect quote do: {:ok, [1, 2, 3]}}"

  IO.puts "quote do: %{a: 1, b: 2} -> #{inspect quote do: %{a: 1, b: 2}}"
  IO.puts "quote do: Enum -> #{inspect quote do: Enum}"
end

