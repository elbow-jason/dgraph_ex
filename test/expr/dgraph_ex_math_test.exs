defmodule DgraphEx.ExprMathTest do
  use ExUnit.Case
  doctest DgraphEx.Expr.Math

  import DgraphEx.Expr.Math
  alias DgraphEx.Expr.Math

  test "math/1 is callable" do
    math(1 + 1)
  end
  
  test "math/1 renders atoms correctly" do
    assert math(:paths / (:num_films / :paths)) |> Math.render == "math(paths / (num_films / paths))"
  end

  test "math/1 renders ints correctly" do
    assert math(1) |> Math.render == "math(1)"
  end
end