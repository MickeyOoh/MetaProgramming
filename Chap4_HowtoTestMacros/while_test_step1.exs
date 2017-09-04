ExUnit.start
Code.require_file("while.exs", __DIR__)

defmodule WhileTest do 
  use ExUnit.Case
  import Loop

  test "Is it really that easy?" do 
    assert Code.ensure_loaded?(Loop)
  end
end

