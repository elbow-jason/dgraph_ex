defmodule DgraphEx.BlockTest do
  use ExUnit.Case
  doctest DgraphEx.Query.Block
  import DgraphEx
  import TestHelpers

  test "func function renders" do
    assert render(func(:person, eq(:name, "bleep"))) == clean_format("""
      person(func: eq(name, \"bleep\"))
    """)
  end

  test "query |> func chain renders" do
    assert render(
      query()
      |> func(:someone, eq(:name, "person"))
    ) == clean_format("""
      {
        someone(func: eq(name, \"person\"))
      }
    """)
  end

  test "block function renders simple example" do
    assert render({
      block(:jason, func: eq(:name, "Jason")), {
        :name
      }
    }) == clean_format("""
      {
        jason(func: eq(name, \"Jason\")) {
          name
        }
      }
    """)
  end

  test "block function renders a complex example" do
    assert render({
      block(:Taraji_films_by_genre_count, func: uid(:G), orderdesc: val(:G)), {
        aliased(:genres, block(:genre, orderdesc: val(:C))), {
           aliased(:genre_name, :name@en)
        },
        film_name: :name@en,
      }
    }) == clean_format("""
      {
        Taraji_films_by_genre_count(func: uid(G), orderdesc: val(G)) {
          genres: genre(orderdesc: val(C)) {
            genre_name: name@en
          } 
          film_name: name@en
        }
      }
    """)
  end

  test "block literal requires `aliased/2` when first member of a tuple a keyword pair" do
    assert render({
      block(:Taraji_films_by_genre_count, func: uid(:G), orderdesc: val(:G)), {
        aliased(:genres, block(:genre, orderdesc: val(:C))), {
           aliased(:genre_name, :name@en)
        },
        film_name: :name@en,
      }
    }) == clean_format("""
      {
        Taraji_films_by_genre_count(func: uid(G), orderdesc: val(G)) {
          genres: genre(orderdesc: val(C)) {
            genre_name: name@en
          }
          film_name: name@en
        }
      }
    """)
  end

  test "block literal does not require `aliased/2` when first member of a tuple is not a keyword pair" do
    assert render({
      block(:Taraji_films_by_genre_count, func: uid(:G), orderdesc: val(:G)), {
        :film_budget,
        block(:genres, orderdesc: val(:C)), {
          :other_field,
          genre_name: :name@en,
        },
        film_name: :name@en,
      }
    }) == clean_format("""
      {
        Taraji_films_by_genre_count(func: uid(G), orderdesc: val(G)) {
          film_budget
          genres(orderdesc: val(C)) {
            other_field
            genre_name: name@en
          }
          film_name: name@en
        }
      }
    """)
    
  end

  test "empty block" do
    assert render({}) == "{ }"
  end

  test "block with simple terms" do
    assert render({
      :name,
      :address,
    }) == clean_format("""
      {
        name
        address
      }
    """)
  end

  test "block with keyword term alias (at the end only)" do
    assert render({
      :name,
      :address,
      age: :years,
    }) == clean_format("""
      {
        name
        address
        age: years
      }
    """)
  end

  test "block with keyword multiple term alias (at the end only)" do
    assert render({
      :name,
      :address,
      age: :years,
      favorite_color: :fav_color,
    }) == clean_format("""
      {
        name
        address
        age: years
        favorite_color: fav_color
      }
    """) 
  end

  test "block with expressions as keywords works" do
    assert render({
      :name,
      :address,
      age: count(:years),
      friends: sum(val(:F)),
    }) == clean_format("""
      {
        name
        address
        age: count(years)
        friends: sum(val(F))
      }
    """)
  end

  test "block with sub-blocks on fields" do
    assert query([
      get: :me,
      func: allofterms(:name@en, "Steven Spielberg"),
      select: {[
        "director.film": query([
          first: -2,
          select: {
            :name@en,
            :initial_release_date,
            genre: query([
              orderasc: :name@en,
              first: 3,
              select: {
                :name@en
              }
            ])
          }
        ])
      ]}
    ]) |> render == clean_format("""
      {
        me(func: allofterms(name@en, "Steven Spielberg")) {
          director.film (first: -2) {
            name@en
            initial_release_date
            genre (orderasc: name@en, first: 3) {
                name@en
            }
          }
        }
      }
    """)
  end


end