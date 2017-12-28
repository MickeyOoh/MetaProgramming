defmodule Fragments do 
  for {name, val} <- [one: 1, two: 2, three: 3] do
    def unquote(name)(), do: unquote(val)
  end
end

defmodule Test do 
  IO.puts File.read!("./fragments.exs")
  a = Fragments.one
  IO.puts a
  IO.puts Fragments.two
end

