defmodule DgraphEx.QueryBlockTest do
  use ExUnit.Case
  doctest DgraphEx.Query.Block

  import DgraphEx
  alias DgraphEx.Query.Block

  test "empty block" do
    assert Block.render({}) == "{ }"
  end

  test "block with simple terms" do
    assert Block.render({
      :name,
      :address,
    }) == "{\nname\naddress\n}"
  end

  test "block with keyword term alias (at the end only)" do
    assert Block.render({
      :name,
      :address,
      age: :years,
    }) == "{\nname\naddress\nage: years\n}"
  end
  

  test "block with keyword multiple term alias (at the end only)" do
    assert Block.render({
      :name,
      :address,
      age: :years,
      favorite_color: :fav_color,
    }) == "{\nname\naddress\nage: years\nfavorite_color: fav_color\n}"
  end

  test "block with expressions as keywords works" do
    assert Block.render({
      :name,
      :address,
      age: count(:years),
      friends: sum(val(:F)),
    }) == "{\nname\naddress\nage: count(years)\nfriends: sum(val(F))\n}"
  end


end