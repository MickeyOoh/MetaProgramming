defmodule ControlFlow do 
  defmacro my_if(expr, do: if_block) do
    IO.puts "first"
    IO.inspect if_block
    if(expr, do: if_block, else: nil)
  end

  defmacro my_if(expr, do: if_block, else: else_block) do
    IO.puts "second"
    IO.inspect else_block
    quote do 
      case unquote(expr) do 
        result when result in [false, nil] -> unquote(else_block)
        _ -> unquote(if_block)
      end
    end
  end
end

"""
iex> c("if_recreated.exs")

iex> require ControlFlow

iex> ControlFlow.my_if 1 == 1 do 
...>   "correct"
...> else
...>   "incorrect"
...> end
"correct"
"""

