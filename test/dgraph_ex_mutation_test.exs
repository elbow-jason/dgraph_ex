defmodule DgraphEx.MutationTest do
  use ExUnit.Case
  doctest DgraphEx.Query.Mutation

  import DgraphEx
  import TestHelpers

  alias DgraphEx.TestPerson, as: Person

  test "render mutation set with a model" do
    assert clean_format("""
      mutation {
        set {
          _:person <name> \"Bleeeeeeeeeeeigh\"^^<xs:string> .
          _:person <age> \"21\"^^<xs:int> .
        }
      }
    """) ==
      mutation()
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



end