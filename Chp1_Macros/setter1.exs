defmodule Setter do 
  defmacro bind_name(string) do 
    quote do
      name = unquote(string)
    end
  end
end

defmodule Test do 
  require Setter
  IO.puts File.read!("setter1.exs")
  name = "Chris"
  str = Setter.bind_name("Max")
  IO.puts "Setten.bind_name(\"Max\") -> #{inspect str}"
  IO.puts "name -> #{inspect name}"
end

