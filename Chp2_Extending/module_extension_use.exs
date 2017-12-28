defmodule Assertion do 
  defmacro __using__(_options) do 
    quote do 
      import unquote(__MODULE__)
      IO.inspect __MODULE__
      def run do 
        IO.puts "Running the tests..."
      end
    end
  end
end

defmodule MathTest do 
  use Assertion
end

defmodule Test do 
  IO.puts File.read!("module_extension_use.exs")
  IO.puts "*** execute result ***"
  MathTest.run
end
