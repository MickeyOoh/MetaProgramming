Code.load_file("./while_step1.exs")

defmodule Test do 
  import Loop

  while Process.alive?(pid) do 
    send pid, {self, :ping}
    receive do 
      {^pid, :pong} -> IO.puts "Got pong"
    after 2000 -> break
    end
  end
end
