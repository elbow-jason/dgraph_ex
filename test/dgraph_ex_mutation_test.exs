defmodule DgraphEx.MutationTest do
  use ExUnit.Case
  doctest DgraphEx.Query.Mutation

  import DgraphEx

  test "render mutation set" do
    result =
      query()
      |> mutation
      |> set
      |> field(:person, :name, "Jason", :string)
      |> render
    assert result == "mutation {\n set { _:person <name> \"Jason\"^^<xs:string> . } \n}"
  end

end