defmodule DgraphEx.QueryFilterTest do
  use ExUnit.Case
  doctest DgraphEx.Query.Filter

  import DgraphEx
  alias DgraphEx.Query.Filter

  test "render filter" do
    assert filter(eq(:beef, "moo"), {
      :name
    }) |> Filter.render == "@filter(eq(beef, \"moo\")) {\nname\n}"
  end

  test "func and filter work together" do
    result =
      query()
      |> func(:person, eq(:name, "Jason"))
      |> filter(eq(:age, 42), {
        :name
      })
      |> render

    assert result ==  "{\nperson(func: eq(name, \"Jason\"))  @filter(eq(age, 42)) {\nname\n}\n}"
  end

end