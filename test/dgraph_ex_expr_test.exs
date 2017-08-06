defmodule DgraphEx.ExprTest do

  use ExUnit.Case
  doctest DgraphEx.Expr

  import DgraphEx
  alias DgraphEx.Expr

  test "render count" do
    assert count(:beef) |> Expr.Count.render == "count(beef)"
  end

  test "render uid as literal" do
    assert uid("0x123") |> Expr.Uid.render == {:ok, "<0x123>"}
  end

  test "render uid as label" do
    assert uid(:beef) |> Expr.Uid.render == "uid(beef)"
  end

  test "render allofterms" do
    assert allofterms(:beef, "cow bull moo") |> Expr.Allofterms.render == "allofterms(beef, \"cow bull moo\")"
  end

  test "render val" do
    assert val(:my_var) |> Expr.Val.render == "val(my_var)"
  end


end