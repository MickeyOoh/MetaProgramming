defmodule Assertion do 

  # {:==, [context: Elixir, import: Kernel], [5, 5]}
  defmacro assert({operator, _, [lhs, rhs]} ) do 
    quote bind_quoted: [operator: operator, lhs: lhs, rhs: rhs] do 
      Assertion.Test.assert(operator, lhs, rhs)
    end
  end
end

##
# We generated a single line of code using our pattern-matched bindings that simply proxies to an Assertion.Test.assert function that we'll write in a moment.  by book
# However, Error happens 
# ** (UndefinedFunctionError) function Assertion.Test.assert/3 is undefined (module Assertion.Test is not available)
#     Assertion.Test.assert(:==, 5, 5)

