## Extending Elixir with Mataprogramming
 Macros aren't just limited to the simple transformations you've done so far. They can be used to perform powerful code generation, save time, eliminate boilerplate, and produce elegant APIs. Once you realize that most of the Elixir standard library is implemented as macros, the possibilities really click about just how much feedom hyou have to extend the language. This can turn your language wish lists into immediate realities.
To continue our journey, we'll add brand-new control flow features to Elixir, extend the module system, and create a testing framework. Elixir puts all the building blocks of the language at our fingertips.
 
### Custom Language Constructs
You've seen that macros allow you to effectively create you own keywords in the language, but they also allow Elixir to be flexible against future requirements. 
For example, instead of waiting for the language to add a parallel for comprehension, you could extend the built-in *for* macro with a new *para* macro that spawns processes to run the comprehenshion in parallel. It could look something like this:

`para(for i <- 1..10 do: 1 * 10)`

para would transform the _for_ AST into code that runs the comprehension in parallel. The original code would gain just one natural _para_ invocation while executing the built-in comprehension in an entirely new way.

#### Re-Creating the if Macro
Consider the _if_ macro from our _unless_ example in the code. The _if_ macro might appear special, but we know it's a macro like any other. Let's re-create Elixir's _if_ macro to get a taste of how easy it is to implement features using the building blocks of the language.

[if_recreated.exs](file:///Users/Mikio/test/Elixir/MetaProgram/Extending/if_recreated.exs)
```if_created.exs
iex> c("if_recreated.exs")
[MyIf]
iex> require ControlFlow
ControlFlow
iex> ControlFlow.my_if 1 == 1 do
...>    "correct"
...> else
...>    "incorrect"
...> end
"correct"
```

####  Adding a while loop to Elixir

```
while Process.alive?(pid) do 
	send pid, {self, :ping}
	receive do 
		{^pid, :pong} -> IO.puts "Got pong"
	after 2000 -> break
	end
end
```

### Smarter Testing with Macros
JavaScript:
expect(value).toBe(true);
expect(value).toEqual(12);
expect(value).toBeGreaterThan(100);

Ruby:
assert value
assert_equal value, 12
assert_operator value, :<=, 100

Elixir
assert value
assert value == 12
assert value <= 100

### Supercharged Assertions
```
defmodule Test do 
  import Assertion
	def run
	  assert 5 == 5
		assert 2 > 0
		assert 10 < 1
	end
end

