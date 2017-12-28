## Chapter4: How to Test Macros
You even saw how macros let you create an expressive test framework. What you haven't seen yet is how to test macros themselves and the code generation they perform. We're going explore how to test macros so you can confidently maintain your libraries. You'll see few techniques for testing code generation and different test-case strategies for the types of metaprogramming involved.

### Setting Up Your Test Suite
Running Elixir tests is usually just a matter of running _mix_ test in your project's directory. Most of the exercises we've done so far have been single Elixir files, outside of a mix project. 

```while_test_step1.exs
ExUnit.start
Code.require_file("while.exs", __DIR__)

defmodule WhileTest do 
  use ExUnit.Case
	import Loop

	test "Is it really that easy?" do 
	  assert Code.ensure_loaded?(Loop)
	end
end


$ elixir while_test.exs

Finished in x.xx seconds (xxxx)
1 tests, 0 failures
```

Elixir's ExUnit test framework makes testing a first-class experience.
This should leave you no excuse for not keeping your code well tested. With just a call to _ExUnit.start_ and _use ExUnit.Case_, we were able to set up a test case for our _Loop_ module, and we can see it's loaded and ready for some real assertions.

### Deciding What to do


