ExUnit.start()

defmodule TestHelpers do

  def clean_format(item) when is_binary(item) do
    item
    |> String.replace(~r/(\s+)/,  " ")
    |> String.trim
  end

end

defmodule DgraphEx.TestPerson do
  use DgraphEx.Vertex

  vertex :person do
    field :name, :string
    field :age,  :int
  end

end