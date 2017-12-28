defmodule Loop do 
  defmacro while(expression, do: block) do
    quote do
      try do 
        for _ <- Stream.cycle([:ok]) do 
          if unquote(expression) do 
            unquote(block)
          else
            #throw :break
            Loop.break
          end  
        end
      catch
        :break -> :ok
      end
    end
  end

  def break, do: throw :break
end

defmodule Test do 
  import Loop

  File.read!("test_while.exs")
  |> IO.puts
  pid = spawn fn ->
    while true do 
      receive do 
        :stop ->
          IO.puts "Stopping..."
          break()
        message ->
          IO.puts "Got #{inspect message}"
      end
    end
  end
  send pid, :hello
  Process.sleep(500)
  send pid, :ping
  Process.sleep(500)
  send pid, :stop
  Process.sleep(500)
  IO.puts " Process.alive? pid -> #{inspect Process.alive? pid}"

end
