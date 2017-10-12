defmodule DgraphEx.MutationTest do
  use ExUnit.Case
  doctest DgraphEx.Mutation

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

  test "render mutation set with a model and virtual field" do
    expected = "mutation { set { _:person <name> \"Bleeeeeeeeeeeigh\"^^<xs:string> .\n_:person <age> \"21\"^^<xs:int> . } }"
    assert expected == mutation()
      |> set(%Person{
        age: 21,
        name: "Bleeeeeeeeeeeigh",
        company_count: 25
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
    assert mutation()
    |> set(%Company{
      name: "TurfBytes",
      owner: %Person{
        name: "Jason"
      }
    })
    |> render
    |> clean_format == clean_format("""
      mutation {
        set {
          _:company <name>  "TurfBytes"^^<xs:string> .
          _:company <owner> _:owner .
          _:owner   <name>  "Jason"^^<xs:string> .
        }
      }
    """)
  end

  test "render mutation schema given a model" do
    assert clean_format("""
      mutation {
        schema {
          name: string @index(exact, terms) .
          owner: uid @reverse .
          location: geo @index(geo) .
        }
    }
    """) == mutation()
    |> schema(Company)
    |> render
    |> clean_format
  end

  test "render mutation delete given (%Muation{}, uid, field_name, value)" do
    assert mutation()
    |> delete(uid("123"), :name, "Jason")
    |> render
    |> clean_format == clean_format("""
      mutation {
        delete {
          <123> <name> "Jason" .
        }
      }
    """)
  end

  test "render mutation delete can take wildcards" do
    assert mutation()
    |> delete("*", :name, "Jason")
    |> render
    |> clean_format == clean_format("""
      mutation {
        delete {
          * <name> "Jason" .
        }
      }
    """)
  end

  test "render mutation delete can delete all the edges" do
    assert mutation()
    |> delete("*", "*", "*")
    |> render
    |> clean_format == clean_format("""
      mutation {
        delete {
          * * * .
        }
      }
    """)
  end

  test "render mutation delete can take a block" do
    assert mutation()
    |> delete({
      field(uid("1234"), :name, "Jason"),
      field(uid("3456"), :name, "Wimu"),
    })
    |> render
    |> clean_format == clean_format("""
      mutation {
        delete {
          <1234> <name> \"Jason\" .
          <3456> <name> \"Wimu\" .
        }
      }
    """)
  end

  test "render mutation delete can take a Field as the second arg" do
    assert mutation()
    |> delete(field(uid("1235"), :name, "Jason"))
    |> delete(field(uid("1234"), :name, "Jason"))
    |> render
    |> clean_format == clean_format("""
      mutation {
        delete {
          <1235> <name> \"Jason\" .
        }
        delete {
          <1234> <name> \"Jason\" .
        }
      }
    """)
  end

  test "render mutation set uses the uid as the subject when provided" do
    assert mutation()
    |> set(%Person{
      _uid_: "6789",
      name: "Buffy",
      age: 20,
    })
    |> render
    |> clean_format == clean_format("""
      mutation {
        set {
          <6789> <name> "Buffy"^^<xs:string> .
          <6789> <age> "20"^^<xs:int> .
        }
      }
    """)
  end

  test "render mutation set can handle nested models with uids" do
    model = %Company{
      _uid_: "1234",
      name: "Flim",
      owner: %Person{
        _uid_: "5678",
        name: "Flinn"
      }
    }

    assert mutation()
    |> set(model)
    |> render
    |> clean_format == clean_format("""
      mutation {
        set {
          <1234> <name> \"Flim\"^^<xs:string> .
          <1234> <owner> <5678> .
          <5678> <name> \"Flinn\"^^<xs:string> .
        }
      }
    """)
  end



end