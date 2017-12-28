defmodule Loop do 

  defmacro while(expression, do: block) do
    quote do
      for _ <- Stream.cycle([:ok]) do 
        if unquote(expression) do 
          unquote(block)
        else
          # break out of loop
        end
      end
    end
  end
end

defmodule Test do 
  import Loop
  cnt = 0
  while true do 
    cnt = cnt + 1
    IO.puts "Looping #{cnt}"
    Process.sleep(1000)
  end
end
