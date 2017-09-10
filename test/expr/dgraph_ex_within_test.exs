defmodule DgraphEx.WithinTest do

  use ExUnit.Case
  doctest DgraphEx.Expr.Within

  import DgraphEx
  import TestHelpers

  test "within renders correctly" do
    geo_json = [[
      [-122.47266769409178, 37.769018558337926 ],
      [ -122.47266769409178, 37.773699921075135 ],
      [ -122.4651575088501, 37.773699921075135 ],
      [ -122.4651575088501, 37.769018558337926 ],
      [ -122.47266769409178, 37.769018558337926],
    ]]

    geo_string = "[[[-122.47266769409178,37.769018558337926],[-122.47266769409178,37.773699921075135],[-122.4651575088501,37.773699921075135],[-122.4651575088501,37.769018558337926],[-122.47266769409178,37.769018558337926]]]"
    assert render(within(:loc, geo_json)) == clean_format("""
      within(loc, #{geo_string})
    """)
  end

end
