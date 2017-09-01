## The Language of Macros

#### The Abstract Syntax Tree( AST)
To master metaprogramming, you first have to understand how Elixir code is respresented internlly by the abstract syntax tree(AST).

```math.exs
iex> c("math.exs")
[Math]
iex> require Math

iex> Math.say 5 + 2
5 plus 2 is 7
7
iex> Math.say 18 * 4
18 times 4 is 72
72
```

we can see that macors, like functions, can have multiple signatures. Havingthe example representation from our quoted results allowed us to easily bind the left-and right-hand side values to variables and print a message accordingly.
To complete the macro, we used _quote_ to return an AST for the caller to replace our *Marh.say* invocations. Here we also used _unqoute_ for the first time. We'll expand on _quote_ and _unquote_ in detail in a moment. For now, all you need to know is these two macros work together to help you build ASTs while keeping track of where your code executes.

### Macro Rules
 Macros give us awesome power, but with great power comes great responsibility.
#### Rule1: Don't Write Macros
We have to remember that writing code to produce code requires special care.It's easy to get caught in our own web of code generation, and many have programs difficult to debug and reason about. There should always be a clear advantage when we attack problems with metaprogramming. In many cases, standard function definitons are a superior choice if code generation is not required.

#### Rule2: Use Macros Gratuitously
Metaprogramming is sometimes framed as complex and fragile. Together, we'll dispel these myths by producing robust, clear programs that offer productive advantages in a fraction of the required code.

### The Abstract Syntax Tree(AST) -- Demystified

#### The Structure of the AST
```
iex> quote do: (5 * 2) - 1 + 7
{:+, [context: Elixir, import: Kernel],
 [{:-, [context: Elixir, import: Kernel],
    [{:*, [context: Elixir, import: Kernel], [5, 2]}, 1]}, 7]}
```
{:+, [...],
  [{:-, [...],
	  [{:*, [...], [5,2]},
	 1]},
 7]}

Lisp:									Elixir(metadata truncated)
(+ ( * 2 3) 1)         quote do: 2 * 3 + 1
                       {:+, _, [{:*, _, [2, 3]}, 1]}

#### AST Literals
```
iex> quote do: :atom
:atom
iex> quote do: 123
123
iex> quote do: 3.14
3.14
iex> quote do: [1, 2, 3]
[1, 2, 3]
iex> quote do: "string"
"string"
iex> quote do: {:ok, 1}
{:ok, 1}
iex> quote do: {:ok, [1,2,3]}
{:ok, [1,2,3]}

iex> quote do: %{a: 1, b: 2}
{:%{}, [], [a: 1, b: 2]}
iex> quote do: Enum
{:__aliases__, [alias: false], [:Enum]}
```

####  Macros: The building Blocks of Elixir
It's time to get our hands dirty and see what macros are all about. You've been promised custom language features, so let's start small by re-creating an essential Elixir feature. From there, we'll expose a few fundamental macro features and see how the AST ties in.

```unless.exs
defmodule ControlFlow do 
  defmacro unless(expression, do: block) do 
	  quote do 
		  if !unquote(expression), do: unquote(block)
		end
	end
end
##
iex> c("unless.exs")
[ControlFlow]
iex> require ControlFlow

iex> ControlFlow.unless 2 == 5, do: "block entered"
"block entered"
iex> ControlFlow.unless 5 == 5 do 
...>   "block entered"
...> end
nil
```
We must first _require ControlFlow_ before invoking its macros in cases where the module hasn't already been imported. Since macros receive the AST representation of arguments, we can accept any valid Elixir expression as the first argument to _unless_ on line 2. In our second argument, we can pattern match directly on the provided *do/end* block and bind its AST value to a variable.
A macro's purpose in life is to take in an AST representation and return an AST representation, so we immediately begin a _quote_ to return an AST. Within the *quote*, we perform a single line of code generation, transforming the _unless_ keyword into an if! expression:

#### **unquote**
The **unquote** macro allows values to be injected into an AST that is being defined. You can think of *quote/unquote* as string interpolation for code.
If you were building up a string and needed to inject the value of a variabe into that string, you would interpolate it. The same goes when constructing an AST. We use _quote_ to begin generating an AST and _unquote_ to inject values from an outside context. This allows the outside bound variables, expression and block, to be injected directly into our if! transformation.
We'll use *Code.eval_quoted* to directly evaluate an AST and return the result.
```
iex> number = 5
5
iex> ast = quote do 
...>    number * 10
...> end
{:*, [context: Elixir, import: Kernel], [{:number, [], Elixir}, 10]}   #*
...>
iex> Code.eval_quoted ast
** (CompileError) nofile:1: undefined function number/0
iex> ast = quote do 
...>   unquote(number) * 10
...> end
{:*, [context: Elixir, import: Kernel], [5, 10]}  #*
iex> Code.eval_quoted ast
{50, []}
```

#### Macro Expansion
When the compiler encounters a macro, it recursively expands it until the code no longer contains any macro calls. Use Figure to take a high-level walk through this process for a simple _ControlFlow.unless_ expression.
The diagram whos the compiler's decision process as it encounters macros in the AST. If it finds a macro, it expands it. If the expanded code also contains macros, those get expanded as well. This expansion recursively executes until all macros have been fully expanded into their final generated code. Now imagine the following block fo code being encountered by the compiler:

Figure 1:
unless 2 == 5
    macro? yes
      |
    expand
if !(2 == 5)
    macro? yes 
      |
    expand
case !(2 == 5)
    macro? no
		  |
	  expansion complete

We know that our _ControlFlow.unless_ macro generates an _if !_ expression, so the compiler would expand the block into the following code:
```
if !(2 == 5) do 
	"block entered"
end
```
Now the compiler sees an _if_ macro and continues expanding the code. You may not know it yet, but Elixir's _if_ macro is implemented internally as a case expression. So the final expression becomes the basic case block.
```
case !(2 == 5) do 
  x when x in [false, nil] ->
	   nil
	_ ->  
	   "block entered"
end
```
Now that the code no longer contains expandable macros, the compiler is finished and would continue compiling the rest of our program. The case macro is a member of a small set of special macros, located in the aptly named Kernel.SpecialForms. These macros are fundamental building blocks in Elixir that cannot be overridden. 

#### Code Injection and the Caller's Context
Macros don't just generate code for the calle, they inject it. We call the place where code is injected a context. A context is the scope of the caller's bindings, imports, and aliases.
To caller of a macro, the context is precious. It holds your view of the world, and by virtue of immutability, you don't expect your variables, imports, and alaises to change out from underneath you.

#### Injecting Code
Because macros are all about injecting code, you have to understand the two contexts in which a macro executes, or you risk generating code in the wrong place. One is the context of the macro definition, and the other is the caller's invocation of the macro.

```callers_context.exs
iex> c("callers_context.exs")
In macro's context (Elixir.Mod)
In caller's context (Elixir.MyModule)
[MyModule, Mod]
...>
iex> MyModule.friendly_info
My name is Elixir.MyModule
My functions are [friendly_info: 0]

:ok
```

#### Hygiene Protects the Callers Context
Hygiene means tht variables, imports and aliases that you define in a macro do not leak into the caller's own definitions.
We must take special consideration with macro hygiene when expanding code, because sometimes it is a necessary evil to implicitly access the caller's scope in an uhygienic way.
The hygiene wasn't a term I had heard before to describe code. But after an introduction, the idea of cleanliness and pollution-free execution really clicked. This safeguard not only prevents accidental namespace clashes, but also requires us to be explicit about reaching into the caller's context.
We've already seen how code injection works, but we haven't tired defining or accessing variables between different contexts. Let's explore a few examples Key in the following code block in _iex_:
```
iex> ast = quote do
...>   if meaning_to_life == 42 do 
...>     "it's true"
...>   else
...>     "it remain to be seen"
...>   end
...> end
{:if, [context: Elixir, import: Kernel],
 [{:==, [context: Elixir, import: Kernel],
    [{:meaning_to_life, [], Elixir}, 42]},
		  [do: "it's true", else: "it remains to be seen"]]}

iex> Code.eval_quoted ast, meaning_to_life: 42
** (CompileError) nofile:1: undefined function meaning_to_life/0
...

```
meaning_to_life wasn't available in the scope of our expression, even though it eas passed as a binding to *Code.eval_quoted*. Elixir takes the safe approach of requiring you to explicitly allow a macro to define bindings in the caller's context. This design forces you to think about whether violating hygiene is necessary.

#### Oveririding Hygiene
We can use the var! macro to explicitly override hygiene within a quoted expression. Let's re-create our previous _iex_ session and use var! to reach into the caller's context.

```
iex> ast = quote do 
...>   if var!(meaning_to_life) == 42 do 
...>     "it's true"
...>   else
...>     "it remains to be seen"
...>   end
...> end
{:if, [context: Elixir, import: Kernel],
 [{:==, [context: Elixir, import: Kernel],
    [{:var!, [context: Elixir, import: Kernel],
		     [{:meaning_to_life, [], Elixir}]}, 42]},
				   [do: "it's true", else: "it remains to be seen"]]}

iex> Code.eval_quoted ast, meaning_to_life: 42
{"it's true", [meaning_to_life: 42]}
iex> Code.eval_quoted ast, meaning_to_life: 100
{"it remains to be seen", [meaning_to_life: 100]}
```
Let's try this out with macros by creating a module that can override a varible that has been previously defined by the caller. Key this into iex and follow along:
```
iex> defmodule Setter do 
...>   defmacro bind_name(string) do
...>     quote do
...>       name = unquote(string)
...>     end
...>   end
...> end

iex> require Setter
iex> name = "Chris"
"Chris"
iex> Setter.bind_name("Max")
"Max"
iex> name
"Chris"

iex> defmodule Setter do 
...>   defmacro bind_name(string) do 
...>     quote do
...>        var!(name) = unquote(string)
...>     end
...>   end
...> end

iex> .......
iex> .....
iex> name
"Max"
```
 
