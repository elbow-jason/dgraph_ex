defmodule DgraphEx.BlockTest do
  use ExUnit.Case
  doctest DgraphEx.Query.Block
  import DgraphEx
  alias DgraphEx.Query.Block

  test "block function renders simple example" do
    b = {
      block(:jason, func: eq(:name, "Jason")), {
        :name
      }
    }
    assert b |> render == "{ jason(func: eq(name, \"Jason\")) { name } }"
  end

  test "block function renders a complex example" do
    b = {
      block(:Taraji_films_by_genre_count, func: uid(:G), orderdesc: val(:G)), {
        aliased(:genres, block(:genre, orderdesc: val(:C))), {
           aliased(:genre_name, :name@en)
        },
        film_name: :name@en,
      }
    }
    assert b |> render == "{ Taraji_films_by_genre_count(func: uid(G), orderdesc: val(G)) { genres: genre(orderdesc: val(C)) { genre_name: name@en } film_name: name@en } }"
  end

  test "block literal requires `aliased/2` when first member of a tuple a keyword pair" do
    b = {
      block(:Taraji_films_by_genre_count, func: uid(:G), orderdesc: val(:G)), {
        aliased(:genres, block(:genre, orderdesc: val(:C))), {
           aliased(:genre_name, :name@en)
        },
        film_name: :name@en,
      }
    }
    assert render(b) == "{ Taraji_films_by_genre_count(func: uid(G), orderdesc: val(G)) { genres: genre(orderdesc: val(C)) { genre_name: name@en } film_name: name@en } }"
  end

  test "block literal does not require `aliased/2` when first member of a tuple is not a keyword pair" do
    b = {
      block(:Taraji_films_by_genre_count, func: uid(:G), orderdesc: val(:G)), {
        :film_budget,
        block(:genres, orderdesc: val(:C)), {
          :other_field,
          genre_name: :name@en,
        },
        film_name: :name@en,
      }
    }
    assert render(b) ==  "{ Taraji_films_by_genre_count(func: uid(G), orderdesc: val(G)) { film_budget genres(orderdesc: val(C)) { other_field genre_name: name@en } film_name: name@en } }"
  end

  test "empty block" do
    assert Block.render({}) == "{ }"
  end

  test "block with simple terms" do
    assert Block.render({
      :name,
      :address,
    }) == "{ name address }"
  end

  test "block with keyword term alias (at the end only)" do
    assert Block.render({
      :name,
      :address,
      age: :years,
    }) == "{ name address age: years }"
  end
  

  test "block with keyword multiple term alias (at the end only)" do
    assert Block.render({
      :name,
      :address,
      age: :years,
      favorite_color: :fav_color,
    }) == "{ name address age: years favorite_color: fav_color }"
  end

  test "block with expressions as keywords works" do
    assert Block.render({
      :name,
      :address,
      age: count(:years),
      friends: sum(val(:F)),
    }) == "{ name address age: count(years) friends: sum(val(F)) }"
  end


end