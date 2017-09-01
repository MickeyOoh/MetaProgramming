defmodule Assertion do 
  # ...
  defmacro __using__(_options) do 
    quote do 
      import unquote(__MODULE__)
      IO.inspect __MODULE__
      #IO.inspect _options
      def run do 
        IO.puts "Running the tests..."
      end
    end
  end
  # ...
end

defmodule MathTest do 
  use Assertion
end

