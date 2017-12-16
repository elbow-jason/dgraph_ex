defmodule DgraphEx.SetTest do
  use ExUnit.Case
  # doctest DgraphEx.Mutation

  import DgraphEx
  import TestHelpers

  alias DgraphEx.ModelPerson, as: Person
  alias DgraphEx.ModelCompany, as: Company

  test "render set with a model" do
    expected = "{ set { _:person <name> \"Bleeeeeeeeeeeigh\"^^<xs:string> .\n_:person <age> \"21\"^^<xs:int> . } }"
    assert expected == %Person{
      age: 21,
      name: "Bleeeeeeeeeeeigh"
    }
    |> set()
    |> render()
  end

  test "render mutation set" do
    assert clean_format("""
      {
        set {
          _:person <name> \"Jason\"^^<xs:string> .
        }
      }
    """) ==
    set()
    |> field(:person, :name, "Jason", :string)
    |> render
  end

  test "render mutation set can handle a nested model" do
    assert %Company{
      name: "TurfBytes",
      owner: %Person{
        name: "Jason"
      }
    }
    |> set
    |> render
    |> clean_format == clean_format("""
      {
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
      {
        schema {
          name: string @index(exact, terms) .
          owner: uid @reverse .
          location: geo @index(geo) .
        }
    }
    """) ==
    schema(Company)
    |> render
    |> clean_format
  end

  test "render mutation delete given (%Muation{}, uid, field_name, value)" do
    assert delete(uid("123"), :name, "Jason")
    |> render
    |> clean_format == clean_format("""
        {
          delete {
            <123> <name> "Jason" .
          }
        }
    """)
  end

  test "render mutation delete can take wildcards" do
    assert delete("*", :name, "Jason")
    |> render
    |> clean_format == clean_format("""
      {
        delete {
          * <name> "Jason" .
        }
      }
    """)
  end

  test "render mutation delete can delete all the edges" do
    assert delete("*", "*", "*")
    |> render
    |> clean_format == clean_format("""
      {
        delete {
          * * * .
        }
      }
    """)
  end

  test "render mutation delete can take a block" do
    assert delete({
      field(uid("1234"), :name, "Jason"),
      field(uid("3456"), :name, "Wimu"),
    })
    |> render
    |> clean_format == clean_format("""
      {
        delete {
          <1234> <name> \"Jason\" .
          <3456> <name> \"Wimu\" .
        }
      }
    """)
  end

  test "render mutation delete can take a Field as the second arg" do
    assert delete(field(uid("1235"), :name, "Jason"))
    |> delete(field(uid("1234"), :name, "Jason"))
    |> render
    |> clean_format == clean_format("""
      {
        delete {
          <1235> <name> \"Jason\" .
          <1234> <name> \"Jason\" .
        }
      }
    """)
  end

  test "render mutation set uses the uid as the subject when provided" do
    assert %Person{
      _uid_: "6789",
      name: "Buffy",
      age: 20,
    }
    |> set()
    |> render()
    |> clean_format() == clean_format("""
      {
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

    assert set(model)
    |> render
    |> clean_format == clean_format("""
      {
        set {
          <1234> <name> \"Flim\"^^<xs:string> .
          <1234> <owner> <5678> .
          <5678> <name> \"Flinn\"^^<xs:string> .
        }
      }
    """)
  end

end
