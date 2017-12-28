defmodule Setter do 
  defmacro bind_name(string) do 
    quote do
      var!(name) = unquote(string)
    end
  end
end

defmodule Test do 
  require Setter
  IO.puts File.read!("setter2.exs")
  name = "Chris"
  str = Setter.bind_name("Max")
  IO.puts "Setten.bind_name(\"Max\") -> #{inspect str}"
  IO.puts "name -> #{inspect name}"
end

