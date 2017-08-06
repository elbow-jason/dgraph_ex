defmodule DgraphExTest do
  use ExUnit.Case
  doctest DgraphEx
  import DgraphEx


  test "render function" do
    result =
      query()
      |> func(:person, eq(:name, "Jason"), {
        :name,
        :address,
      })
      |> render
    assert result == "{ person(func: eq(name, \"Jason\")) { name address } }"
  end

  test "render function with alias" do
    result =
      query()
      |> func(:person, eq(:name, "Jason"), {
        :address,
        named: :name,
      })
      |> render
    assert result == "{ person(func: eq(name, \"Jason\")) { address named: name } }"
  end

  test "render function with count alias" do
    result =
      query()
      |> func(:person, eq(:name, "Jason"), {
        :address,
        names: count(:name),
      })
      |> render

    assert result == "{ person(func: eq(name, \"Jason\")) { address names: count(name) } }"
  end

  test "render function with string value eq expr" do
    result =
      query()
      |> func(:person, eq(:name, "Jason"), {
        :address,
        :name,
      })
      |> render

    assert result == "{ person(func: eq(name, \"Jason\")) { address name } }"
  end

  test "render function with int value eq expr" do
    result =
      query()
      |> func(:person, eq(:name, 123), {
        :address,
        :name,
      })
      |> render

    assert result == "{ person(func: eq(name, 123)) { address name } }"
  end

  test "render function with bool value eq expr" do
    result =
      query()
      |> func(:person, eq(:name, true), {
        :address,
        :name,
      })
      |> render

    assert result == "{ person(func: eq(name, true)) { address name } }"
  end

  test "render function with date value eq expr" do
    {:ok, test_written_at} = Date.new(2017, 8, 5)
    result =
      query()
      |> func(:person, eq(:name, test_written_at), {
        :address,
        :name,
      })
      |> render

    assert result == "{ person(func: eq(name, 2017-08-05T00:00:00.0+00:00)) { address name } }"
  end

  test "render function with uid literal expression" do
    result =
      query()
      |> func(:person, uid("0x9"), {
        :address,
        :name,
      })
      |> render
    assert result == "{ person(func: uid(0x9)) { address name } }"
  end

  test "render function eq with embedded count expr" do
    result =
      query()
      |> func(:ten_friends, eq(count(:friend), 10, :int), {
        :name,
      })
      |> render
    assert result == "{ ten_friends(func: eq(count(friend), 10)) { name } }"
  end

  # {
  #   dirs(func: uid(ID)) @filter(gt(val(total), 100)) {
  #     name@en
  #     total_actors : val(total)
  # }
  test "compilcated query 1" do
    # booyah
    result =
      query()
      |> func(:dirs, uid(:ID))
      |> filter(gt(val(:total), 100), {
        :name@en,
        total_actors: val(:total),
      })
      |> render
    assert result == "{ dirs(func: uid(ID)) @filter(gt(val(total), 100)) { name@en total_actors: val(total) } }"
  end

  # {
  #   ID as var(func: allofterms(name@en, "Steven")) {
  #     director.film {
  #       num_actors as count(starring)
  #     }
  #     total as sum(val(num_actors))
  #   }

  #   dirs(func: uid(ID)) @filter(gt(val(total), 100)) {
  #     name@en
  #     total_actors : val(total)
  #   }
  # }
 
  test "compilcated query 2" do
    # booyah
    result = {
      :ID, :as, func(:var, allofterms(:name@en, "Steven")), {
        :"director.film", {
          :num_actors, :as, count(:starring)
        },
        :total, :as, sum(val(:num_actors))
      },
      func(:dirs, uid(:ID)), filter(gt(val(:total), 100)), {
        :name@en,
        total_actors: val(:total),
      }
    }
    assert render(result) ==  "{ ID as var(func: allofterms(name@en, \"Steven\")) { director.film { num_actors as count(starring) } total as sum(val(num_actors)) } dirs(func: uid(ID)) @filter(gt(val(total), 100)) { name@en total_actors: val(total) } }"
  end

   
  test "compilcated query 3" do
    result = {
      func(:person, anyofterms(:name, "Jason")), {
        :name,
        :address,
      }
    }
    assert render(result) == "{ person(func: anyofterms(name, \"Jason\")) { name address } }"
  end


end
