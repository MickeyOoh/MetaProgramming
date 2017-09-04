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

We'll start by defining a _while_ macro within a _Loop_ module:
while_step1.exs:
```
defmodule Loop do
  defmacro while(expression, do: block) do 
	  quote do 
		  for _ <- Stream.cycle([:ok]) do 
				if unquote(exression) do 
					unquote(block)
				else
          # break out of loop
				end
			end
		end
	end
end
$$
iex> c "while_step1.exs"
[Loop]
iex> import Loop
iex> while true do 
...>   IO.puts "looping!"
...> end
looping!
looping!
looping!
looping!
...
^C^C
```

We began by pattern matching directly on the provided expression and block of code. Like all macros, we need to produce an AST for the caller, so we started a quoted expression. 
Next, we effectively created an infinite loop by consuming the infinite stream, _stream.cycle([:ok])_. Within our _for_ block, we injected the _expression_ into an _if/else_ clause to conditionally execute the provided block of code.

Now we need the ability to break out of execution once the expression is no longer true. Elixir's _for_ comprehension has no built-in way to terminate early, but with a careful _try/catch_ block, we can throw a value to stop execution. 

while_step2.exs:
```
defmodule Loop do 
  defmacro while(expression, do: block) do 
	  quote do 
		  try do 
			  for _ <- Stream.cycle([:ok]) do 
					if unquote(expression) do 
						unquote(block)
					else
						throw :break
					end
				end
			catch
			  :break -> :ok
			end
		end
	end
end
$$$$$
iex> c "while_step2.exs"
iex> import Loop
iex> run_loop = fn ->
...>   pid = spawn(fn -> :timer.sleep(4000) end)
...>   while Process.alive?(pid) do 
...>     IO.puts "#{inspect :erlang.time} strayin' alive!"
...>     :timer.sleep 1000
...>   end
...> end
#Function<20.99386804/0 in :erl_eval.expr/5>
iex> run_loop.()
{14, 17, 0} Stayin' alive!
{14, 17, 1} Stayin' alive!
{14, 17, 2} Stayin' alive!
{14, 17, 3} Stayin' alive!
:ok
iex(5)> 
```

We now have a functioning _while_ loop. Careful use of _throw_ allows us to break out of execution whenever the _while_ expression is no longer true. Let's provide a _break_ function to allow the caller to expicitly terminate execution:
```while.exs
defmodule Loop do 
  defmacro while(expression, do: block) do 
	  quote do
		  try do
			  for _ <- Stream.cycle([:ok]) do 
					if unquote(expression) do 
						unquote(block)
					else
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
$$ iex
iex> c "while.exs"
iex> import Loop
iex> 
pid = spawn fn ->
  while true do 
		receive do 
		  :stop ->
			  IO.puts "Stopping..."
				break
			message ->
			  IO.puts "Got #{inspect message}"
		end
	end
end
iex> send pid, :hello
Got :hello
:hello
iex> send pid, :ping
Got :ping
:ping
iex> send pid, :stop
Stopping...
:stop
iex> Process.alive? pid
false
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

