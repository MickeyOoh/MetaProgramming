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


