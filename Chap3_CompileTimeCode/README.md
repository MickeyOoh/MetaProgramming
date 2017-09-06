## Advanced Compile-Time Code Generation
We've performed compile-time code generation through careful use of macros. Now let's shift gears and exploit Elixir's module system.
With advanced metaprogramming, we can embed data and behavior within modules directly from outside sources of information. This technique can remove countless lines of boilerplate, while producing highly optimized programs.
We'll start by exploring how Elixir embeds an entire unicode database at compile time for its robust Unicode support. Next, we'll build MIME-type validation and internationalization libraries, while applying compile-time optimization that aren't possible in many languages.
Knowing when and where to use this technique will allow us to construct fast, maintainable programs in strikingly few lines of code.

### Generating Fucntions from External Data
Turning raw data into code might sound impactical, but it's an extremely nice solution to a number of problems. Ever wonder how Elixir manages its fnatastic String Unicode support? The way it goes about it is my favorite metaprogramming example to date. The _String.Unicode_ module of the standdard library dynamically generates thousands of function definitions from external data when compiled.




### Building an Internationalization Library
Almost all user-facing applications are best served by an internationalization layer where language snippets can be stored and referenced programmatically.
Let's use code generation to produce an internationalization library in fewer lines of code than you thought possible. This is the most advanced exercise you've done so far, so let's start by breaking down our implementation into a rubric that you can use to attack complex metaprogramming problems.

#### Step 1: Plan Your Macro API
The first step of our _Translator_ implementation is to plan the surface area of our macro API. This is often called README Driven Development. It helps tease out our library goals and figure out what macros we need to make them happen. Our goal is to produce the following API.

[i18n.exs](i18n.exs)

```
iex> I18n.t("en", "flash.hello", first: "Chris", last: "McCord")
"Hello Chris McCord!"
iex> I18n.t("fr", "flash.hello", first: "Chris", last: "McCord")
"Salut Chris McCord!"
iex> I18n.t("en", "users.title")
"Users"
```
We'll support _use Translator_ to allow any module to have a dictionary of translations compiled directly as t/3 function definitions. At minimum, we need to define a '__using__' macro to wire up some imports and attributes, and a _locale_ macro to handle locale registrations. 

#### Step 2: Implement a Skeleton Module with Metaprogramming Hooks
Our next step is to implement the skeleton of our _Translator_ module by defining the '__using__', '__before_compile__', and _locale_ macros that we planned when fleshing out the surface area of our API.

[translator_step2.exs](translator_step2.exs)
```
defmodule Translator do 

  defmacro __using__(_options) do 
    quote do 
      Module.register_attribute __MODULE__, :locales, accumulate: true,
                                      persist: false
      import unquote(__MODULE__), only: [locale: 2]
      @before_compile unquote(__MODULE__)
    end
  end
  defmacro __before_compile__(env) do 
    compile(Module.get_attribute(env.module, :locales))
  end

  defmacro locale(name, mappings) do 
    quote bind_quoted: [name: name, mappings: mappings] do 
      @locales {name, mappings}
    end
  end
  def compile(translations) do 
    # TBD: Return AST for all translation function definitions
  end
end
```

We wired up the '__before_compile__' hook in our *Translator.__using__* macro. We added a placeholder to delegate to a *compile* function to carry out the code generation from our locale registrations.

#### Step 3: Generate Code from Your Accumelated Module Attributes
Let's begin the bulk of our implementation by transforming the locale registrations into function definitions within our _compile_ placeholder from Step2. Our goal is to map our translations into a large AST of t/3 functions.
We also need to add catch-all clauses that return {:error, :no_translation}.

Update your *compile/1* function with the following code:
[translator_step3.exs](translator_step3.exs)
```
def compile(translations) do 
  translations_ast = for {locale, mappings} <- translations do 
	  deftranslations(locale, "", mappings)
	end

	quote do 
	  def t(locale, path, bindings \\ [])
		unquote(translations_ast)
		def t(_locale, _path, _bindings), do: {:error, :no_translation}
	end
end

defp deftranslations(locales, current_path, mappings) do 
  # TBD: Return an AST of the t/3 function defs for the given locale
end
```
Let's check progress:
```
iex> c "translator_step3.exs"
iex> c "i18n.exs"
iex> I18n.t("en", "flash.hello", first: "Chris". last: "McCord")
{:error, :no_translation}
```

Fill in your deftranslations function with this code:
```
defp deftanslations(locale, current_path, mappings) do
  for {key, val} <- mappings do 
		path = append_path(current_path, key)
		if Keyword.keyword?(val) do 
			deftranslations(locale, path, val)
		else
			quote do 
			  def t(unquote(locale), unquote(path), bindings) do 
				  unquote(interpolate(val))
				end
			end
		end
	end
end

defp interpolate(string) do 
  string # TBD interpolate bindings within string
end

defp append_path("", next), do: to_string(next)
defp append_path(current, next), do: "#{current}.#{next}"
```
[translator_step4.exs](translator_step4.exs)

#### Macro.to_string: Make Sense of Your Generated Code

#### Final Step: Identify Areas for Compile-Time Optimizations

