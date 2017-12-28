defmodule Debugger do
  Application.put_env(:debugger, :log_level, :debug)
  defmacro log(expression) do 
    if Application.get_env(:debugger, :log_level) == :debug do 
      quote do 
        IO.puts "==============="
        IO.inspect unquote(expression)
        IO.puts "==============="
        unquote(expression)
      end
    else
      IO.puts "else -> " 
      expression
    end
  end
end

defmodule Test do 
  require Debugger

  #Application.put_env(:debugger, :log_level, :debug)
  #IO.inspect Application.get_env(:debugger, :log_level)
  Process.sleep(1000)
  remote_api_call = fn -> IO.puts("calling remote API...") end

  Debugger.log(remote_api_call.())
  Process.sleep(1000)
end

