defmodule DgraphExTest do
  use ExUnit.Case
  doctest DgraphEx
  import DgraphEx


  test "render function" do
    result =
      query()
      |> func(:person, eq(:name, "Jason", :string), [
        :name,
        :address,
      ])
      |> render
      |> TestHelper.only_spaces
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
      |> TestHelper.only_spaces
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
      |> TestHelper.only_spaces
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
      |> TestHelper.only_spaces
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
      |> TestHelper.only_spaces
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
      |> TestHelper.only_spaces
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
      |> TestHelper.only_spaces
    assert result == "{\nperson(func: eq(name, 2017-08-05T00:00:00.0+00:00)) {\naddress\nname\n} }"
  end

  test "render function with uid literal expression" do
    result =
      query()
      |> func(:person, uid("0x9"), [
        :address,
        :name,
      ])
      |> render
      |> TestHelper.only_spaces
    assert result == "{\nperson(func: uid(0x9)) {\naddress\nname\n} }"
  end

end
