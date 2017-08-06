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
    assert result == "{\nperson(func: eq(name, \"Jason\")) {\nname\naddress\n}\n}"
  end

  test "render function with alias" do
    result =
      query()
      |> func(:person, eq(:name, "Jason"), {
        :address,
        named: :name,
      })
      |> render
    assert result == "{\nperson(func: eq(name, \"Jason\")) {\naddress\nnamed: name\n}\n}"
  end

  test "render function with count alias" do
    result =
      query()
      |> func(:person, eq(:name, "Jason"), {
        :address,
        names: count(:name),
      })
      |> render

    assert result == "{\nperson(func: eq(name, \"Jason\")) {\naddress\nnames: count(name)\n}\n}"
  end

  test "render function with string value eq expr" do
    result =
      query()
      |> func(:person, eq(:name, "Jason"), {
        :address,
        :name,
      })
      |> render

    assert result == "{\nperson(func: eq(name, \"Jason\")) {\naddress\nname\n}\n}"
  end

  test "render function with int value eq expr" do
    result =
      query()
      |> func(:person, eq(:name, 123), {
        :address,
        :name,
      })
      |> render

    assert result == "{\nperson(func: eq(name, 123)) {\naddress\nname\n}\n}"
  end

  test "render function with bool value eq expr" do
    result =
      query()
      |> func(:person, eq(:name, true), {
        :address,
        :name,
      })
      |> render

    assert result == "{\nperson(func: eq(name, true)) {\naddress\nname\n}\n}"
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

    assert result == "{\nperson(func: eq(name, 2017-08-05T00:00:00.0+00:00)) {\naddress\nname\n}\n}"
  end

  test "render function with uid literal expression" do
    result =
      query()
      |> func(:person, uid("0x9"), {
        :address,
        :name,
      })
      |> render
    assert result == "{\nperson(func: uid(0x9)) {\naddress\nname\n}\n}"
  end

  test "render function eq with embedded count expr" do
    result =
      query()
      |> func(:ten_friends, eq(count(:friend), 10, :int), {
        :name,
      })
      |> render
    assert result == "{\nten_friends(func: eq(count(friend), 10)) {\nname\n}\n}"
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
    assert result == "{\ndirs(func: uid(ID))  @filter(gt(val(total), 100)) {\nname@en\ntotal_actors: val(total)\n}\n}"
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
    result =
      render({
        :ID, :as, func(:var, allofterms(:name@en, "Steven"), {
          :"director.film", {
            :num_actors, :as, count(:starring)
          },
          :total, :as, sum(val(:num_actors))
        }),
        func(:dirs, uid(:ID)), filter(gt(val(:total), 100), {
          :name@en,
          total_actors: val(:total),
        })
      })
    assert result == "{\nID as var(func: allofterms(name@en, \"Steven\")) {\ndirector.film\n{\nnum_actors as count(starring)\n}\ntotal as sum(val(num_actors))\n}\ndirs(func: uid(ID)) \n@filter(gt(val(total), 100)) {\nname@en\ntotal_actors: val(total)\n}\n}"
  end

end
