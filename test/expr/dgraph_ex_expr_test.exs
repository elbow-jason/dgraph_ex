defmodule DgraphEx.ExprTest do

  use ExUnit.Case
  doctest DgraphEx.Expr

  import DgraphEx
  alias DgraphEx.Expr

  test "render count" do
    assert count(:beef) |> Expr.Count.render == "count(beef)"
  end

  test "render uid as literal" do
    assert uid("0x123") |> Expr.Uid.render == "<0x123>"
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

  test "render regexp with Regex" do
    assert regexp(:name, ~r/Jason/) |> Expr.Regexp.render == "regexp(name, /Jason/)"
  end

  test "render regexp with string" do
    assert regexp(:name, "\d{4}") |> Expr.Regexp.render == "regexp(name, /\d{4}/)"
  end

  test "render anyofterms" do
    assert anyofterms(:beef, "cow bull moo") |> Expr.Anyofterms.render == "anyofterms(beef, \"cow bull moo\")"
  end

  test "render anyoftext" do
    assert anyoftext(:beef, "cow bull moo") |> Expr.Anyoftext.render == "anyoftext(beef, \"cow bull moo\")"
  end

  test "render alloftext" do
    assert alloftext(:beef, "cow bull moo") |> Expr.Alloftext.render == "alloftext(beef, \"cow bull moo\")"
  end

  test "render lt" do
    assert lt(:age, 100) |> Expr.Lt.render == "lt(age, 100)"
  end

  test "render le" do
    assert le(:age, 100) |> Expr.Le.render == "le(age, 100)"
  end

  test "render gt" do
    assert gt(:age, 100) |> Expr.Gt.render == "gt(age, 100)"
  end

  test "render ge" do
    assert ge(:age, 100) |> Expr.Ge.render == "ge(age, 100)"
  end

  test "render sum" do
    assert sum(val(:experience)) |> Expr.Sum.render == "sum(val(experience))"
  end

  test "render avg" do
    assert avg(val(:experience)) |> Expr.Avg.render == "avg(val(experience))"
  end

  test "render min" do
    assert min(val(:experience)) |> Expr.Min.render == "min(val(experience))"
  end

  test "render max" do
    assert max(val(:experience)) |> Expr.Max.render == "max(val(experience))"
  end

  test "render has" do
    assert has(:age) |> Expr.Has.render == "has(age)"
  end


end