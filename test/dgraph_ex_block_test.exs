defmodule DgraphEx.BlockTest do
  use ExUnit.Case
  doctest DgraphEx.Query.Block

  import DgraphEx
  alias DgraphEx.Query.Block

  test "block function renders simple example" do
    b = [
      block(:jason, func: eq(:name, "Jason")), [
        :name
      ]
    ]
    assert render(b) == "{\njason(func: eq(name, \"Jason\"))\n{\nname\n}\n}"
  end

  test "block function renders a complex example" do
    b = {
      block(:Taraji_films_by_genre_count, func: uid(:G), orderdesc: val(:G)), [
        block(:genres, orderdesc: val(:C)), [
          genre_name: :name@en
        ],
        film_name: :name@en,
      ]
    }
    assert render(b) == "{\njason(func: eq(name, \"Jason\"))\n{\nname\n}\n}"
  end

  test "empty block" do
    assert Block.render([]) == "{ }"
  end

  test "block with simple terms" do
    assert Block.render([
      :name,
      :address,
    ]) == "{\nname\naddress\n}"
  end

  test "block with keyword term alias (at the end only)" do
    assert Block.render([
      :name,
      :address,
      age: :years,
    ]) == "{\nname\naddress\nage: years\n}"
  end
  

  test "block with keyword multiple term alias (at the end only)" do
    assert Block.render([
      :name,
      :address,
      age: :years,
      favorite_color: :fav_color,
    ]) == "{\nname\naddress\nage: years\nfavorite_color: fav_color\n}"
  end

  test "block with expressions as keywords works" do
    assert Block.render([
      :name,
      :address,
      age: count(:years),
      friends: sum(val(:F)),
    ]) == "{\nname\naddress\nage: count(years)\nfriends: sum(val(F))\n}"
  end


end