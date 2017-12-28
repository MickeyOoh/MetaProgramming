defmodule Test do 
  ast = quote do 
    if meaning_to_life == 42 do 
      "it's true"
    else
      "it remains to be seen"
    end
  end
  IO.inspect ast
  Code.eval_quoted ast, meaning_to_life: 42

end

