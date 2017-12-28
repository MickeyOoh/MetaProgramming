## Chapter 5: Creating an HTML Domain-Specific Language
One of the most powerful ways to use macros is to build domain-specific languages(DSLs). They let you create a custom layer in the language to attack problems closer to your application domain. This can make your code easier to write and make it more clearly represent the problem being solved.
With DSLs, you can codify your business requirements and operate at a shared level of abstraction with the callers of your library.

### Getting Domain Specific
Before jumping into code, let's look at what DSLs are all about and how metaprogramming makes them so easy. In Elixir, DSLs are languages defined by custom macros.

HTML Specification
```
markup do 
  div class: "row" do
	  h1 do
		  text title
		end
	  article do 
		  p do: text "Welcome!"
		end
	end
	if logged_in? do
		a href: "edit.html" do 
		  text "Edit"
		end
	end
end
$$$ expected output
"<div class\"row\">
   <h1>Domain Specific Languages</h1>
	 <article><p>Welcome!</p></article>
	 <a href=\"edit.html\">Edit</a>
</div>"
```

### Start by Defining the Minimum Viable API
We need to decide how to design our API. The HTML spec includes some 117 valid tags, but we need a smaller surface area to begin our DSL. At this point you might be tempted to fire up your editor and start defining all 117 tags as individual macros. There's a better way.
Since we define a mini language with macros when creating DSLs, the best way to begin is 
> to define the samllest set of macros possible to serve as a basis for the boarder macro DSL.
> Instead of immediately planning to support the entire HTML spec as macros, let's start with a refined set of macros that can still speak the HTML language.
The smallest API of our HTML library would contain a *tag* macro for tag construction, a *text* macro for injecting plain text, and a _markup_ macro to wrap the base of our implementation. 

Rewrite the previous examples as if these were the only available macros:
```
markup do
  tag :div, class: "row" do 
	  tag :h1 do 
		  text title
		end
		tag :article do 
		  tag :article do
			  tag :p, do: text "Welcome!"
			end
		end
	end
	if logged_in? do
		tag :a, href: "edit.html" do
		  text "Edit"
		end
	end
end
"<div class\"row\">
  <h1>Domain Specific Languages</h1>
	<article><p>Welcome!</p></article>
	<a href=\"edit.html\">Edit</a>
</div>"
```
Let's list the requirements of our minimum HTML API. First, it needs to support _markup_, _tag_, and _text_ macros. The second and less obvious requirement is that our library must maintain an output buffer state while the markup is being generated.  
To understand why our library requires mutable state, let's imagine we tried to keep state by rebinding a buffer variable every time the tag macro was called.

```
markup do						# buff = ""
  div do 						# buff = buff <> "<div>"
	  h1 do 					# buff = buff <> "<h1>"
		  text "hello"	# buff = buff <> "hello"
		end							# buff = buff <> "</h1>"
	end								# buff = buff <> "</div>"
end									# buff

iex> buff
"<div><h1>hello</h1></div>"
```

### Keeping State with Agents
Elixir Agents provide a simple way to store and retrieve state in your application. Let's see how easy it is to manage state with an Agent process.

```
iex> {:ok, buffer} = Agent.start_link fn -> [] end
{:ok, #PID<x.xxx.x>}
iex> Agent.get(buffer, fn state -> state end)
[]
iex> Agent.update(buffer, &["<h1>Hello</h1>" | &1])
:ok
iex> Agent.get(buffer, &(&1))
["<h1>Hello</h1>"]
iex> for i <- 1..3, do: Agent.update(buffer, &["<td><#{i}</td>" | &1])
[:ok, :ok, :ok]
iex> Agent.get(buffer, &(&1))
["<td><3</td>", "<td><2</td>", "<td><1</td>", "<h1>Hello</h1>"]
```

[html_step1.exs](html_step1.exs)

[html_step1_render.exs](html_step1_render.exs)

```
iex> c "html_step1.exs"
[Html]
iex> c "html_step1_render.exs"
[Temlate]
iex> Template.render
"<table>
  <tr>
  <td>Cell 0</td>
	<td>Cell 1</td>
	<td>Cell 2</td>
	<td>Cell 3</td>
	<td>Cell 4</td>
	<td>Cell 5</td>
	</tr>
</table>
<div>Some Nested Content</div>
```

### Support the Entire HTML Spec with Macros
A single _tag_ macro simply won't cut it. Let's up our sophistication by supporting all 117 valid HTML tags. 

[tags.txt](tags.txt)
```
form
frame
frameset
h1
head
header
```

[html_step2.exs](html_step2.exs)

```
iex> c "html_step2.exs"
[Html]
iex> c "html_step2_render.exs"
[Template]
iex> Template.render
"<table>
  <tr> 
	<td>Cell 0</td>
	<td>Cell 1</td>
	<td>Cell 2</td>
	<td>Cell 3</td>
	<td>Cell 4</td>
	<td>Cell 5</td>
	</tr>
</table>
<div>some Nested Content</div>
```

### Enhance Your API with HTML Attribute Support


