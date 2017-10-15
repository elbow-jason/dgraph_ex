defmodule DgraphExTest do
  use ExUnit.Case
  doctest DgraphEx
  import DgraphEx
  import TestHelpers

  alias DgraphEx.Query
  alias Query.{
    Groupby,
  }

  alias DgraphEx.ModelPerson,   as: Person
  alias DgraphEx.ModelCompany,  as: Company

  test "groupby/1 function" do
    assert DgraphEx.groupby(:age) == %Groupby{predicate: :age}
  end

  test "render function" do
    result =
      query()
      |> func(:person, eq(:name, "Jason"))
      |> select({
        :name,
        :address,
      })
      |> render
    assert result == "{ person(func: eq(name, \"Jason\")) { name address } }"
  end

  test "render function with alias" do
    result =
      query()
      |> func(:person, eq(:name, "Jason"))
      |> select({
        :address,
        named: :name,
      })
      |> render
    assert result == "{ person(func: eq(name, \"Jason\")) { address named: name } }"
  end

  test "render function with count alias" do
    result =
      query()
      |> func(:person, eq(:name, "Jason"))
      |> select({
        :address,
        names: count(:name),
      })
      |> render

    assert result == "{ person(func: eq(name, \"Jason\")) { address names: count(name) } }"
  end

  test "render function with string value eq expr" do
    assert query()
      |> func(:person, eq(:name, "Jason"))
      |> select({
        :address,
        :name,
      })
      |> render == clean_format("""
        {
          person(func: eq(name, \"Jason\")) {
            address
            name
          }
        }
      """)
  end

  test "render function with int value eq expr" do
    result =
      query()
      |> func(:person, eq(:name, 123))
      |> select({
        :address,
        :name,
      })
      |> render

    assert result == "{ person(func: eq(name, 123)) { address name } }"
  end

  test "render function with bool value eq expr" do
    result =
      query()
      |> func(:person, eq(:name, true))
      |> select({
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
      |> func(:person, eq(:name, test_written_at))
      |> select({
        :address,
        :name,
      })
      |> render

    assert result == "{ person(func: eq(name, 2017-08-05T00:00:00.0+00:00)) { address name } }"
  end

  test "render function with uid literal expression" do
    result =
      query()
      |> func(:person, uid("0x9"))
      |> select({
        :address,
        :name,
      })
      |> render
    assert result == "{ person(func: uid(0x9)) { address name } }"
  end

  test "render function eq with embedded count expr" do
    result =
      query()
      |> func(:ten_friends, eq(count(:friend), 10, :int))
      |> select({
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
      |> filter(gt(val(:total), 100))
      |> select({
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

  test "blade runner example" do
    # https://docs.dgraph.io/query-language/#applying-filters
    # the second one down
    example_from_the_website = "{ bladerunner(func: anyofterms(name, \"Blade Runner\")) @filter(le(initial_release_date, \"2000\")) { _uid_ name@en initial_release_date netflix_id } }"
    b = {
      block(:bladerunner, func: anyofterms(:name, "Blade Runner")),
      filter(le(:initial_release_date, "2000")), {
        :_uid_,
        :name@en,
        :initial_release_date,
        :netflix_id,
      }
    }
    assert render(b) == example_from_the_website
  end

  test "DgraphEx.into/3 works for error tuples" do
    assert DgraphEx.into({:error, :the_bleep_went_blop}, Person, :spy) == {:error, :the_bleep_went_blop}
  end

  test "DgraphEx.into/3 works for ok tuples" do
    payload = %{
      "spy" => [
        %{
          "name" => "John Lakeman",
          "_uid_" => "123",
        }
      ]
    }
    assert DgraphEx.into({:ok, payload}, Person, :spy) == %{
      spy: [
        %DgraphEx.ModelPerson{
          _uid_: "123",
          age: nil,
          name: "John Lakeman",
          works_at: nil,
        }
      ]
    }
  end

  test "DgraphEx.into/3 works for populating modules from maps" do
    payload = %{
      "spy" => [
        %{
          "name" => "John Lakeman",
          "_uid_" => "123",
        }
      ]
    }
    assert DgraphEx.into(payload, Person, :spy) == %{
      spy: [
        %DgraphEx.ModelPerson{
          _uid_: "123",
          age: nil,
          name: "John Lakeman",
          works_at: nil,
        }
      ]
    }
  end

  test "DgraphEx.into/3 works for invalid keys models from maps" do
    payload = %{
      "spy" => [
        %{
          "name" => "John Lakeman",
          "_uid_" => "123",
        }
      ]
    }
    assert DgraphEx.into(payload, Person, :nope) == {:error, {:invalid_key, :nope}}
  end

  test "DgraphEx.into/3 works for populating struct from maps" do
    payload = %{
      "spy" => [
        %{
          "name" => "John Lakeman",
          "_uid_" => "123",
        }
      ]
    }
    assert DgraphEx.into(payload, %Person{}, :spy) == %{
      spy: [
        %DgraphEx.ModelPerson{
          _uid_: "123",
          age: nil,
          name: "John Lakeman",
          works_at: nil,
        }
      ]
    }
  end


  test "DgraphEx.into/3 works for nested populating struct from maps" do
    payload = %{
      "spy" => [
        %{
          "name" => "John Lakeman",
          "_uid_" => "123",
          "works_at" => %{
            "_uid_" => "456",
            "name" => "Blublublub"
          }
        }
      ]
    }
    assert DgraphEx.into(payload, %Person{works_at: Company}, :spy) == %{
      spy: [
        %DgraphEx.ModelPerson{
          _uid_: "123",
          age: nil,
          name: "John Lakeman",
          works_at: %Company{
            _uid_: "456",
            name: "Blublublub",
          },
        }
      ]
    }
  end

  test "resolve given valid field name" do
    assert DgraphEx.resolve_field(Person, :company_count) == {:ok, "count(works_at)"}
  end

  test "resolve given valid field name without resolve" do
    assert DgraphEx.resolve_field(Person, :works_at) == {:ok, :no_resolver}
  end

  test "resolve given invalid valid field name" do
    assert DgraphEx.resolve_field(Person, :company_counters) == {:error, :invalid}
  end

end
