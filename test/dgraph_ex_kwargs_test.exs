defmodule DgraphEx.KwargsTest do
  use ExUnit.Case
  doctest DgraphEx.Query.Kwargs
  alias DgraphEx.Query.Kwargs, as: K
  import DgraphEx

  test "a query call returns a query" do
    assert K.query([]) == %DgraphEx.Query{}
  end

  test "a simple get func select query renders correctly" do
    q = query get: :person,
             func: eq(:name, "Jason"),
           select: { :name, :age, :height }
    assert render(q) == "{ person(func: eq(name, \"Jason\")) { name age height } }"
  end

  test "aliasing with :as works" do
    q = query as: :person,
            func: eq(:name, "Jason"),
          select: { :name, :age, :height }
    assert render(q) == "{ person as var(func: eq(name, \"Jason\")) { name age height } }"
  end

  test ":filter works" do
    q = query get: :person,
             func: eq(:name, "Jason"),
           filter: lt(:age, 15),
           select: { :name, :age, :height }
    assert render(q) == "{ person(func: eq(name, \"Jason\")) @filter(lt(age, 15)) { name age height } }"
  end

  test "directives works" do
    q = query get: :person,
             func: eq(:name, "Jason"),
        normalize: true,
          cascade: true,
     ignorereflex: true,
           select: { :name, :age, :height }
    assert render(q) == "{ person(func: eq(name, \"Jason\")) @normalize @cascade @ignorereflex { name age height } }"
  end

  test "directives list works" do
    q = query get: :person,
             func: eq(:name, "Jason"),
       directives: [:cascade, :ignorereflex],
           select: { :name, :age, :height, }

    assert render(q) == "{ person(func: eq(name, \"Jason\")) @cascade @ignorereflex { name age height } }"
  end


  test "groupby works" do
    q = query groupby: :age,
               select: { :name, :age }
    assert render(q) == "{ @groupby(age) { name age } }"
  end

  test "executors work" do
    q = query orderasc: :age,
                 first: 5
    assert render(q) == "(first: 5, orderasc: age)"
  end
end
