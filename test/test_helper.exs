ExUnit.start()

defmodule TestHelper do

  def only_spaces(string) do
    string
    |> String.replace(~r/\s{2,}/, " ")
  end

end