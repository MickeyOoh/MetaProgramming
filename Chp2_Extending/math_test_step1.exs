Code.load_file("./assertion0.exs")
defmodule MathTest do 
  use Assertion

  test "integers can e added and subtrcted" do 
    assert 1 + 1 == 2
    assert 2 + 3 == 5
    assert 5 - 5 == 10
  end
end

MathTest.run
