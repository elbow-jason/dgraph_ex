defmodule DgraphEx.UidTest do

  use ExUnit.Case
  doctest DgraphEx.Expr.Uid

  import DgraphEx
  alias DgraphEx.Expr.Uid

  test "given a string a uid renders a plain-old uid literal" do
    assert uid("0x9") |> Uid.render == "<0x9>"
  end
end
