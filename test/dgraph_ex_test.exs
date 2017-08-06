defmodule DgraphExTest do
  use ExUnit.Case
  doctest DgraphEx
  import DgraphEx

  test "the truth" do
    assert 1 + 1 == 2
  end

  def only_spaces(string) do
    string
    |> String.replace(~r/\s{2,}/, " ")
    # |> String.replace(~r/\s/, " ")
  end


  test "render function" do
    result =
      query()
      |> func(:person, eq(:name, "Jason", :string), [
        :name,
        :address,
      ])
      |> render
      |> only_spaces
    assert result == "{\nperson(func: eq(name, \"Jason\")) {\nname\naddress\n} }"
  end

  test "render function with alias" do
    result =
      query()
      |> func(:person, eq(:name, "Jason", :string), [
        :address,
        named: :name,
      ])
      |> render
      |> only_spaces
    assert result == "{\nperson(func: eq(name, \"Jason\")) {\naddress\nnamed: name\n} }"
  end

  test "render function with count alias" do
    result =
      query()
      |> func(:person, eq(:name, "Jason", :string), [
        :address,
        names: count(:name),
      ])
      |> render
      |> only_spaces
    assert result == "{\nperson(func: eq(name, \"Jason\")) {\naddress\nnames: count(name)\n} }"
  end

  test "render function with string value eq expr" do
    result =
      query()
      |> func(:person, eq(:name, "Jason", :string), [
        :address,
        :name,
      ])
      |> render
      |> only_spaces
    assert result == "{\nperson(func: eq(name, \"Jason\")) {\naddress\nname\n} }"
  end

  test "render function with int value eq expr" do
    result =
      query()
      |> func(:person, eq(:name, 123, :int), [
        :address,
        :name,
      ])
      |> render
      |> only_spaces
    assert result == "{\nperson(func: eq(name, 123)) {\naddress\nname\n} }"
  end

  test "render function with bool value eq expr" do
    result =
      query()
      |> func(:person, eq(:name, true, :bool), [
        :address,
        :name,
      ])
      |> render
      |> only_spaces
    assert result == "{\nperson(func: eq(name, true)) {\naddress\nname\n} }"
  end

  test "render function with date value eq expr" do
    {:ok, test_written_at} = Date.new(2017, 8, 5)
    result =
      query()
      |> func(:person, eq(:name, test_written_at, :date), [
        :address,
        :name,
      ])
      |> render
      |> only_spaces
    assert result == "{\nperson(func: eq(name, 2017-08-05T00:00:00.0+00:00)) {\naddress\nname\n} }"
  end

  test "render mutation set" do
    result =
      query()
      |> mutation
      |> set
      |> field(:person, :name, "Jason", :string)
      |> render
      |> only_spaces
    assert result == "mutation { set { _:person <name> \"Jason\"^^<xs:string> . } }"
  end

end
