defmodule Test do 
  @spec registered?(atom) :: boolean
  def registered?(name) do 
    names = Process.registered()
    Enum.any?(names, fn n -> n == name end)
  end
  def registered?(name) do 
    name in Process.registered()
  end
  def registered?(name),
    do: Process.whereis(name) != nil
end


