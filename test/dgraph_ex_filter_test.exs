defmodule DgraphEx.FilterTest do
  use ExUnit.Case
  doctest DgraphEx.Query.Filter

  import DgraphEx
  import TestHelpers

  test "render filter" do
    assert filter(eq(:beef, "moo")) |> render == "@filter(eq(beef, \"moo\"))"
  end

  test "func and filter work together" do
    result =
      query()
      |> func(:person, eq(:name, "Jason"))
      |> filter(eq(:age, 42))
      |> select({
        :name
      })

    assert render(result) ==  clean_format("""
      {
        person(func: eq(name, \"Jason\")) @filter(eq(age, 42)) {
          name
        }
      }
    """)
  end

  test "filter can take a list with `and`, `or`, and/or `not` atoms" do
    result =
      query()
      |> func(:person, eq(:name, "Jason"))
      |> filter([gt(:age, 30), :and, lt(:age, 65)])
      |> select({
        :name
      })

    assert render(result) ==  clean_format("""
      {
        person(func: eq(name, "Jason")) @filter(lt(age, 65) AND gt(age, 30)) {
          name
        }
      }
    """)
  end

end