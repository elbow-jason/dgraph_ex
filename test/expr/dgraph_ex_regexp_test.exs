defmodule DgraphEx.RegexpTest do
  use ExUnit.Case
  doctest DgraphEx.Expr.Regexp

  import DgraphEx

  test "regex can render with an normal elixir Regex" do
    assert render(regexp(:name, ~r/Jason/)) == "regexp(name, /Jason/)"
  end

  test "regex can render with an normal elixir string" do
    assert render(regexp(:name, "Jason")) == "regexp(name, /Jason/)"
  end

  test "regex can render with an elixir Regex with options" do
    assert render(regexp(:name, ~r/Jason/im)) ==  "regexp(name, /Jason/im)"
  end


end
