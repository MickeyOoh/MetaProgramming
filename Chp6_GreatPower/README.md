## With Great Powe Comes Great Responsibility (and Fun!)

### When and Where to Use Macros
It's easy to think that every library you write needs macros. This isn't th case. Macros should be reserved for specialized cases where the solution can't be implemented easily as normal function definitions. 
Whenever you're writing code and reach for _defmacro_, stop and ask yourself whether your solution requires code generation. Sometimes code generation is absolutely required, but other times it's easy to get carried away with macros where you could've just written functions instead.

In some cases, the choice for macros is easy. For things like control flow,
where access to the AST expression is required., macros are the obvious choice.

```
defmodule ControlFlow do
  def if(expr, do: block, else: else_block) do
	  case expr do
		  result when result in [nil, false] -> else_block
			result -> block
		end
	end
end

iex> ControlFlow.if true do
...>   IO.puts "It's true!"
...> else
...>   IO.puts "It's false!"
...> end
It's true!
It's false!
```
Both of the IO.puts expressions were evaluated because they were passed to the if function at runtime. Macros are an obvious requirement here because we must convert the expression at compile time into a case expression to avoid runtime evauation of both clauses. Other times the choice is not as obvious.

In creating Phoenix, an Elixir web framework, I used macros for its router layer. The case for macros in the Phoenix router is twofold. First, it allows for an exprssive and easy-to-use routing DSL. Second, it can generate many clauses internally that a user would've had to write by hand.  

Here's a minimal Phoenix router that routes HTTP requests to controller modules.

```
defmodule MyRouter do
  use Phoenix.Router
	Pipeline :browser do 
	  plug :accepts, ~w(html)
		plug :fetch_session
	end
	
	scope "/" do 
	  pipe_through :browser
		get "/pages", PageController, :index
		get "/pages/:page", UserController, :show
		resources "/users", UserController do
      resources "/comments", CommentContoller
		end
	end
end
```
After MyRouter is compiled, Phoenix generates function heads on the module that look something like this:
```
defmodule MyRouter do 
  ...
	def match(conn, "GET", 		["pages"])
	def match(conn, "GET",    ["pages", page])
	def match(conn, "GET",    ["users", "new"])
	def match(conn, "POST",   ["users"])



```

### Avoiding Common Pitfalls
As with any powerful tool, it's easy to cut yourself. Throughout my Elixir exprience, a few cmmmon mistakes have appeared that are easy to avoid in retrospect but can work havoc on your code base over time if ignored. Let's find out ways to avoid getting caught in your own web of code generation.

### Don't use When You Can import
One of the most common mistakes newly minted metaprogammers make is treating _use_ as a way to mix in functions from other modules. This tempting idea conflates the concept to a mix-in from other languages, where you can include methods and functions from one module into another. 
Consider a _StringTransforms_ module that defines a number of string transformation functions to use around your code base. You might write something like this for easy sharing across different modules:
```
defmodule StringTransforms do 
  defmacro __using__(_opts) do 
    quote do 
		  def title_case(str) do 
			  str
				|> String.split(" ")
				|> Enum.map(fn <<first::utf8, rest::binary>> ->
				  String.upcase(List.to_string([first])) <> rest
				end)
				|> Enum.join(" ")
			end
			def dash_case(str) do 
			  str
				|> String.downcase
				|> String.replace(~r/[^\w]/, "-")
			end	
      # ... hundreds of more lines of string transform functions
		end
	end
end
defmodule User do 
  use StringTransforms
	def friendly_id(user) do 
	  dash_case(user.name)
	end
end

iex> User.friendly_id(%{name: "Elixir lang"})
"elixir-lang"
```

[transforms.exs](transforms.exs)

A __using__ macro is defined to house a quoted expression of some string transformation functions, such as *title_case* and *dash_case*. 
The *User* module uses *StringTransforms* so that the functions are injected into its context. This allows *dash_case* to be called within the friendly_id function. It works, but it's very wrong.

Here, we've abused *use* to inject functions such as *title_case* and *dash_case* into another module. It works, but we don't need to inject code at all. Elixir's import gives us all we need. Let's refactor the *StringTransforms* module to remove all code generation:

```
defmodule StringTransforms do 
  def title_case(str) do
    str
    |> String.split(" ")
    |> Enum.map(fn <<first::utf8, rest::binary>> -> 
         String.upcase(List.to_string([first])) <> rest
       end)
    |> Enum.join(" ")
  end
  def dash_case(str) do
    str
    |> String.downcase
    |> String.replace(~r/[^\w]/, "-")
  end
  # ... hundreds of more lines of string transform functions
end

defmodule User do
  import StringTransforms
  def friendly_id(user) do 
    dash_case(user.name)
  end
end
$$
iex> friendly_id(%{name: "Elixir Lang"})
"elixir-lang"
```

We removed the '__using__' block and relied on *import* to share our functions in the *User* module. Import gives us everything we had in our previous solution while allowing all string functions to be defined as regular definitions in the *StringTransforms* module. The **use** macro should never be used solely for mix-in style functionality.
Importing functions serves the same purpose without generating code. Even for cases where you need *use* for code generation, you should only inject code that requires it, and you should import the rest as normal functions.

### Avoid Injecting Large Amounts of Code

One common mistake is doing too much of it. Let's say you've weighted the pros and cons, and you know macros are required to solve your problem. The mistake you might make at this point is to go all out with _quote_ blocks and inject hundreds of lines of code. This can make your code fragile and impossible to debug. Whenever you're injecting code, it should be your goal to delegate our of the caller's context as soon as possible. This way, your library code stays in your library, and the injected code is the bare minimum to call out from the caller's context into your library functions.

To give you an idea of this design process, consider the email library that we envisioned in To DSL or Not to DSL?. Even though it wouldn't make a good DSL, let's imagine how we would implement it as a macro-enhanced library. The library will need to inject a *send_email* function into caller's module where functions can be defined to send different types of messages. The *send_email* function will apply email provider configuration for connecting to a mail service. 

```
defmodule Emailer do 
  defmacro __using__(config) do 
	  quote do
		  def send_email(to, from, subject, body) do 
			  host = Dict.fetch!(unquote(config), :host)
				user = Dict.fetch!(unquote(config), :username)
				pass = Dict.fetch!(unquote(config), :password)

			  :gen_smtp_client.send({to, [from], subject}, [
				   relay: host,
					 username: user,
					 password: pass
				])
			end
		end
	end
end

defmodule MyMailer do 
  use Emailer, username: "myusername",
	             password: "mypassword",
							 host: "smtp.example.com"
	def send_welcome_email(user) do 
	  send_email user.email, "support@example.com", "Welcome!", """
		Welcome aboard! Thanks for signing up...
		"""
	end
end
```
At first glance, it might not look too bad. You're injecting *send_email* into the caller's module, and it's only a handful of lines of code. But don't fall into this trap. 
The issue is that the current implementation houses the validation of the configuration options as well as the details of sending an email directly in the injected code. This causes your implementation details to leak outside to every using module. It also makes your code harder to test.

Let's rewrite the library to delegate out of the caller's context to perform the email-sending work:
```
defmodule Emailer do 
  defmacro __using__(config) do 
	  quote do 
		  def send_email(to, from, subject, body) do 
			  Emailer.send_email(unquote(config), to, from, subject, body)
			end
		end
	end

  def send_email(config, to, from, subject, body) do 
	  host = Dict.fetch!(config, :host)
		user = Dict.fetch!(config, :username)
		pass = Dict.fetch!(config, :password)

		:gen_smtp_client.send({to, [from], subject}, [
		  relay: host,
			useranem: user,
			password: pass
		])
	end
end
```

Notice how we pushed all the business logic and work of sending an email back into the *Emailer* module? The injected *send_email/4* function delegates out immediately and passes along the caller's configuration. 
This subtle shift places all of the implementation concerns as a normal function definition on your library module. Your API remains exactly the same, but now you have the benefits of testing your *Emailer.send_email/5* function directly. Another benefit is that stack traces now come from your *Emailer* module, not from a confusing generated code block within the caller's module.
```
[username: "myusername", password: "mypassword", host: "smtp.example.com"]
|> Emailer.send_email("you@example.com", "me@example.com", "Hi!", "")
```

### Kernel.SpecialForms:Know Your Environment and Limitations
Elixir is an incredibly extensible language, but even it has areas that are special and not overridable. Knowing where these are and why they exist will help keep you grounded in what is and isn't possible when extending the language.
The Kernel SpecialForms module defines a set of constructs that you can't override. They make up the basic building blocks of the language and contain macros such as alias, case, {}, and <<>>. 

* __ENV__: Returns a Macro ENV struct containing current environment infomation
* __MODULE__: Returns the current module name as an atom, equivalent to __ENV__.module
* __DIR__: the current directory
* __CALLER__: Returns the caller's environment information as a Macro.ENV struct

```
iex> __ENV__.file
"iex"
iex> __ENV__.line
2
iex> __ENV__.vars
[]
iex> name = "Elixir"
iex> version = "~> 1.0"
iex> __ENV__.vars
[name: nil, version: nil]
iex> binding
[name: "Elixir", version: "~> 1.0"]
```

### Bending the Rules
#### Abusing Valid Elixir Syntax
Rewriting the AST to change the meaning of valid Elixir expressions probably sounds evil to most people. In some cases, it's actually a powerful tool.
Consider Elixir's Eco library, which is a database wrapper and language Integragrated Query system. 

```
query = from user in user,
    where: user.age > 21 and user.enrolled == true,
		select: user
```
Ecto converts this completely valid Elixir expression into a string of SQL. It abuses operators suchas *in*, *and*, *==*, and *>* to form SQL expressions out of valid Elixir code.

Ecto is a large project worthy of its own book, but let's imagine how we could implement a similar library. 
```
iex> quote do 
...>   from user in user, 
...>      where: user.age > 21 and user.enrolled == true,
...>      select: user
...> end
{:from, [],
 [{:in, [context: Elixir, import: Kernel],
    [{:user, [], Elixir}, {:__aliases__, [alias: false], [:User]}]},
		  [where: {:and, [context: Elixir, import: Kernel],
			    [{:>, [context: Elixir, import: Kernel],
					      [{{:., [], [{:user, [], Elixir}, :age]}, [], []}, 21]},
								     {:==, [context: Elixir, import: Kernel],
										       [{{:., [], [{:user, [], Elixir}, :enrolled]}, [], []}, true]}]},
													    select: {:user, [], Elixir}]]}
```
Looking at the AST of an Ecto query, we can begin to see how macros would let us abuse Elixir syntax for fun and profit. 

#### Learn by Tinkering

```
iex> quote do 
...>   the answer should be between 3 and 5
...>   the list should contain 10
...>   the User name should resemble "Max"
...> end |> Macro.to_string |> IO.puts
(
  the(answer(should(be(between(3 and 5)))))
	  the(list(should(contain(10))))
		  the(user(name(should(resemble("Max")))))
			)
:ok
```

