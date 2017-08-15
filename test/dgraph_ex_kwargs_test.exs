defmodule DgraphEx.KwargsTest do
  use ExUnit.Case
  doctest DgraphEx.Kwargs

  import DgraphEx
  import TestHelpers

  alias DgraphEx.ModelPerson, as: Person
  
  test "a query call returns a query" do
    assert query([]) == %DgraphEx.Query{}
  end

  test "a simple get func select query renders correctly" do
    assert clean_format("""
      {
        person(func: eq(name, \"Jason\")) {
          name
          age
          height
        }
      }
    """) == render query([
         get: :person,
        func: eq(:name, "Jason"),
      select: { :name, :age, :height }
    ])
  end

  test "aliasing with :as works" do
    assert clean_format("""
      {
        person as var(func: eq(name, \"Jason\")) {
          name
          age
          height
        }
      }
    """) == render query([
          as: :person,
        func: eq(:name, "Jason"),
      select: { :name, :age, :height }
    ])
  end

  test ":filter works" do
    assert clean_format("""
      { 
        person(func: eq(name, \"Jason\")) @filter(lt(age, 15)) {
          name
          age
          height
        }
      }
    """) == render query([
         get: :person,
        func: eq(:name, "Jason"),
      filter: lt(:age, 15),
      select: { :name, :age, :height }
    ])
  end

  test "directives works" do
    assert clean_format("""
      {
        person(func: eq(name, \"Jason\")) @normalize @cascade @ignorereflex {
          name
          age
          height
        }
      }
    """) == render query([ 
              get: :person,
             func: eq(:name, "Jason"),
        normalize: true,
          cascade: true,
     ignorereflex: true,
           select: {
             :name,
             :age,
             :height,
           },
    ])
  end

  test "directives list works" do
    assert TestHelpers.clean_format("""
      {
        person(func: eq(name, \"Jason\")) @cascade @ignorereflex {
          name
          age
          height
        }
      }
    """) == query([
              get: :person,
             func: eq(:name, "Jason"),
       directives: [:cascade, :ignorereflex],
           select: {
             :name,
             :age,
             :height,
           }
    ]) |> render
  end


  test "groupby works" do
    assert TestHelpers.clean_format("""
      {
        @groupby(age) {
          name
          age
        }
      }
    """) == render query([
      groupby: :age,
      select: {
        :name,
        :age,
      },
    ])
  end

  test "executors work" do
    assert query(orderasc: :age, first: 5) |> render == "(orderasc: age, first: 5)"
  end

  test "complex query" do
    genres_count_var =
      query([
          as: :genres,
        func: has(:"~genre"),
      select: {
        as(:num_genres, count(:"~genre")),
      },
    ])

    reversed_genre =
      query([
        orderasc: val(:num_genres),
           first: 5,
          select: {
            :name@en,
            genres: val(:num_genres),
          }
      ])

    genres_selector =
      query([
          get: :genres,
          func: uid(:genres),
      orderasc: :name@en,
        select: {
          :name@en,
          "~genre": reversed_genre,
        },
      ])
    complex_query =
      query([
        genres_count_var,
        genres_selector,
      ])
    assert render(complex_query) == TestHelpers.clean_format("""
      {
        genres as var(func: has(~genre)) {
          num_genres as count(~genre)
        } 
        genres(func: uid(genres), orderasc: name@en) {
          name@en
          ~genre (orderasc: val(num_genres), first: 5) {
            name@en
            genres: val(num_genres)
          }
        }
      }
    """)
  end

  test "mutation set works" do
    assert mutation([
      set: %Person{
        name: "jason",
        age: 33,
      }
    ])
    |> render
    |> clean_format == clean_format("""
      mutation {
        set {
          _:person <name> \"jason\"^^<xs:string> .
          _:person <age> \"33\"^^<xs:int> .
        }
      }
    """)
  end
end
