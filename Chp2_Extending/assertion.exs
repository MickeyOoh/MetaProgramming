defmodule Assertion do 

  defmacro __using__(_options) do 
    quote do 
      import unquote(__MODULE__)
      Module.register_attribute __MODULE__, :tests, accumulate: true
      #def run do 
      #  IO.puts "use Running the tests (#{inspect @tests})"
      #end
      @before_compile unquote(__MODULE__)
    end
  end

  defmacro __before_compile__(_env) do 
    quote do 
      def run, do: Assertion.Test.run(@tests, __MODULE__)
    end
  end

  defmacro test(description, do: test_block) do 
    IO.puts description
    test_func = String.to_atom(description)
    quote do 
      @tests {unquote(test_func), unquote(description)}
      def unquote(test_func)(), do: unquote(test_block)
    end
  end
  # {:==, [context: Elixir, import: Kernel], [5, 5]}
  defmacro assert({operator, _, [lhs, rhs]}) do 
    quote bind_quoted: [operator: operator, lhs: lhs, rhs: rhs] do 
      Assertion.Test.assert(operator, lhs, rhs)
    end
  end
end

defmodule Assertion.Test do 
  def run(tests, module) do 
    Enum.each tests, fn {test_func, description} ->
      case apply(module, test_func, []) do 
        :ok          -> IO.write "."
        {:fail, reason}  -> IO.puts """

        ===================================
        FAILURE: #{description}
        ===================================
        #{reason}
        """
      end
    end
  end

  def assert(:==, lhs, rhs) when lhs == rhs do 
    # IO.write "."
    :ok
  end
  def assert(:==, lhs, rhs) do 
    {:fail, """ 
      Expected:       #{lhs}
      to be equal to: #{rhs}
      """
    }
  end
  def assert(:>, lhs, rhs) when lhs > rhs do 
    #IO.write "."
    :ok
  end
  def assert(:>, lhs, rhs) do 
    {:fail, """
      Expected:           #{lhs}
      to be greater than: #{rhs}
      """
    }
  end
end
