defmodule ControlFlow do
  defmacro unless(expression, do: block) do 
    quote do 
      if !unquote(expression), do: unquote(block)
    end
  end
end

defmodule Test do 
  #require ControlFlow
  alias  ControlFlow
  fil = File.read!("unless.exs")
  IO.puts fil
  chk= unless 2 == 5, do: "block entered"
  IO.puts "unless 2 == 5, do: \"block entered\" -> #{chk}"
  chk = unless 5 == 5 do
    "block enterted"
  end
  IO.puts "unless 5 == 5 chk -> #{inspect chk}"
end

