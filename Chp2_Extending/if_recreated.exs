defmodule ControlFlow do 
  defmacro my_if(expr, do: if_block) do
    if(expr, do: if_block, else: nil)
  end

  defmacro my_if(expr, do: if_block, else: else_block) do
    quote do 
      case unquote(expr) do 
        result when result in [false, nil] -> unquote(else_block)
        _ -> unquote(if_block)
      end
    end
  end
end

defmodule Test do
  import ControlFlow
  IO.puts File.read!("if_recreated.exs") 
  str = my_if 1 == 1 do 
          "correct"
        else
          "incorrect"
        end
  IO.inspect str
end
