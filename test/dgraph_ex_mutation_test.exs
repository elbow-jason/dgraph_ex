defmodule DgraphEx.MutationTest do
  use ExUnit.Case
  doctest DgraphEx.Query.Mutation

  import DgraphEx
  import TestHelpers

  alias DgraphEx.ModelPerson, as: Person
  alias DgraphEx.ModelCompany, as: Company

  test "render mutation set with a model" do
    expected = "mutation { set { _:person <name> \"Bleeeeeeeeeeeigh\"^^<xs:string> .\n_:person <age> \"21\"^^<xs:int> . } }"
    assert expected == mutation()
      |> set(%Person{
        age: 21,
        name: "Bleeeeeeeeeeeigh"
      })
      |> render
  end

  test "render mutation set" do
    assert clean_format("""
      mutation {
        set {
          _:person <name> \"Jason\"^^<xs:string> .
        }
      }
    """) ==
    mutation()
    |> set
    |> field(:person, :name, "Jason", :string)
    |> render
  end

  test "render mutation set can handle a nested model" do
    expected = "mutation { set { _:company <name> \"TurfBytes\"^^<xs:string> .\n_:company <owner> _:owner .\n_:owner <name> \"Jason\"^^<xs:string> . } }"
    assert expected == mutation()
    |> set(%Company{
      name: "TurfBytes",
      owner: %Person{
        name: "Jason"
      }
    })
    |> render
  end


end