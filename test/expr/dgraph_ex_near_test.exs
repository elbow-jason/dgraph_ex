defmodule DgraphEx.NearTest do

  use ExUnit.Case
  doctest DgraphEx.Expr.Near

  import DgraphEx
  import TestHelpers

  test "near renders correctly" do
    assert render(near(:loc, [123.456, 0.1], 1000)) == clean_format("""
      near(loc, [123.456,0.1], 1000)
    """)
  end

end
