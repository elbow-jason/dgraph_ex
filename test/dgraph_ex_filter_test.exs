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

end