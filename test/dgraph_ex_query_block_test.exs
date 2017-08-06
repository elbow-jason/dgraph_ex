defmodule DgraphEx.QueryBlockTest do
  use ExUnit.Case
  doctest DgraphEx.Query.Block

  import DgraphEx
  alias DgraphEx.Query.Block

  test "empty block" do
    assert Block.render({}) == "{ }"
  
  end

end