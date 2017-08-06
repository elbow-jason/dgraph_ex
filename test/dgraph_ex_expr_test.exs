defmodule DgraphEx.ExprTest do

  use ExUnit.Case
  doctest DgraphEx.Expr

  import DgraphEx
  alias DgraphEx.Expr

  test "render count" do
    assert count(:beef) |> Expr.Count.render == "count(beef)"
  end

  test "render uid" do
    assert uid("0x123") |> Expr.Uid.render == {:ok, "<0x123>"}
  end

end