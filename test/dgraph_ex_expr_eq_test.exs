defmodule DgraphEx.ExprEqTest do

  use ExUnit.Case
  doctest DgraphEx.Expr.Eq

  import DgraphEx

  alias DgraphEx.Expr


  test "render eq with predicate, literal, and type" do
    assert eq(:beef, "cow bull moo", :string) |> Expr.Eq.render == "eq(beef, \"cow bull moo\")"
  end

  test "render eq with predicate and literal, no type" do
    assert eq(:beef, "cow bull moo") |> Expr.Eq.render == "eq(beef, \"cow bull moo\")"
  end

  test "render eq with val and literal" do
    assert eq(val(:c), "cow bull moo") |> Expr.Eq.render == "eq(val(c), \"cow bull moo\")"
  end

  test "render eq with count and literal" do
    assert eq(count(:friend), 10) |> Expr.Eq.render == "eq(count(friend), 10)"
  end

  test "render eq with predicate and list" do
    assert eq(:fav_color, ["blue", "green", "brown"]) |> Expr.Eq.render == ~s{eq(fav_color, ["blue","green","brown"])}
  end
 
end
