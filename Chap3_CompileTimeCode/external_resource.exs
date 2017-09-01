defmodule Mime do 

  @external_resouce mimes_path = Path.join([__DIR__, "mimes.txt"])

  for line <- File.stream!(mimes_path, [], :line) do
    # ....

  end
end

