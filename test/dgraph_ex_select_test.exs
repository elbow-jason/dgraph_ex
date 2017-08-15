defmodule DgraphEx.SelectTest do
  use ExUnit.Case
  doctest DgraphEx.Query.Select

  alias DgraphEx.ModelPerson, as: Person
  alias DgraphEx.ModelCompany, as: Company

  import TestHelpers
  import DgraphEx

  test "select can destructure a module with a struct into a block for selection" do
    result =
      query()
      |> func(:person, eq(:name, "Jason"))
      |> select(Person)
      |> render
    assert result == clean_format("""
      {
        person(func: eq(name, \"Jason\")) {
          _uid_
          age
          name
          works_at
        }
      }
    """)
  end

  test "select can destructure a struct into a block for selection" do
    result =
      query()
      |> func(:person, eq(:name, "Jason"))
      |> select(%Person{})
      |> render
    assert result == clean_format("""
      {
        person(func: eq(name, \"Jason\")) {
          _uid_
          age
          name
          works_at
        }
      }
    """)
  end

  test "select can destructure nested models into a select" do
    result =
    query()
    |> func(:person, eq(:name, "Jason"))
    |> select(%Person{
      works_at: %Company{
        owner: %Person{}
      },
    })
    |> render
  assert result == clean_format("""
    {
      person(func: eq(name, \"Jason\")) {
        _uid_
        age
        name
        works_at {
          _uid_
          name
          owner
          {
            _uid_
            age
            name
            works_at
          }
        }
      }
    }
  """)
  end

  test "a model's field can be removed from a select by setting it to false" do
    result =
    query()
    |> func(:person, eq(:name, "Jason"))
    |> select(%Person{
      works_at: false,
      age:      false,
    })
    |> render
  assert result == clean_format("""
    {
      person(func: eq(name, \"Jason\")) {
        _uid_
        name
      }
    }
  """)
  end

end
