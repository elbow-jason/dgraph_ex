ExUnit.start()

defmodule TestHelpers do

  def clean_format(item) when is_binary(item) do
    item
    |> String.replace(~r/(\s+)/,  " ")
    |> String.trim
  end

end

Code.load_file("./test/model_company.exs")
Code.load_file("./test/model_person.exs")
