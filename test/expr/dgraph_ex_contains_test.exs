defmodule DgraphEx.ContainsTest do

  use ExUnit.Case
  doctest DgraphEx.Expr.Contains

  import DgraphEx
  import TestHelpers

  test "contains renders correctly with a shape" do
    geo_json = [
      [-122.47266769409178, 37.769018558337926 ],
      [ -122.47266769409178, 37.773699921075135 ],
      [ -122.4651575088501, 37.773699921075135 ],
      [ -122.4651575088501, 37.769018558337926 ],
      [ -122.47266769409178, 37.769018558337926],
    ]

    geo_string = "[[-122.47266769409178,37.769018558337926],[-122.47266769409178,37.773699921075135],[-122.4651575088501,37.773699921075135],[-122.4651575088501,37.769018558337926],[-122.47266769409178,37.769018558337926]]"
    assert render(contains(:loc, geo_json)) == clean_format("""
      contains(loc, #{geo_string})
    """)
  end

  test "contains renders correctly with a point" do
    geo_json = [-122.47266769409178, 37.769018558337926 ]

    geo_string = "[-122.47266769409178,37.769018558337926]"
    assert render(contains(:loc, geo_json)) == clean_format("""
      contains(loc, #{geo_string})
    """)
  end

end
