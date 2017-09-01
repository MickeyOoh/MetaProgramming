defmodule Assertion do 
  # ..
  @macrodoc """
  we were able to inject a stubbed run/0 function directly into the MathTest module via our Assertion.extend macro. Assertion.extend is just a regular macro that returned an AST containing the run/0 definition.
  """
  defmacro extend(options \\ []) do 
    quote do 
      import unquote(__MODULE__)

      def run do 
        IO.puts "Running the tests..."
      end
    end
  end
end
defmodule MathTest do 
  @doc """
   
  """
  require Assertion 
  Assertion.extend
end

