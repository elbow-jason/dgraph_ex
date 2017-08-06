defmodule DgraphEx.QueryFilterTest do
  use ExUnit.Case
  doctest DgraphEx.Query.Filter

  import DgraphEx
  alias DgraphEx.Query.Filter

  test "render filter" do
    assert filter(eq(:beef, "moo")) |> Filter.render == "@filter(eq(beef, \"moo\"))"
  end

end