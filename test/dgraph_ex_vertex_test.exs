defmodule DgraphEx.VertexTest do
  use ExUnit.Case
  doctest DgraphEx.Vertex

  alias DgraphEx.Vertex

  alias DgraphEx.ModelPerson,  as: Person
  alias DgraphEx.ModelCompany, as: Company

  test "populate_fields/2 flattens the entire model and it's submodels" do
    person = %Person{
      _uid_: "5678",
      age: 34,
      name: "Flinn",
      works_at: nil,
    }
    company = %Company{
      _uid_: "1234",
      name: "Flim",
      owner: person,
    }
    fields = Vertex.populate_fields(:company, company)
    person_uid = %DgraphEx.Expr.Uid{type: :literal, value: "5678"}
    company_uid = %DgraphEx.Expr.Uid{type: :literal, value: "1234"}
    triples = 
      fields
      |> Enum.map(fn f -> {f.subject, f.predicate, f.object} end)
    assert {:company,   :_uid_,   company_uid}  in triples
    assert {:company,   :name,    "Flim"}       in triples
    assert {:company,   :owner,   person_uid}   in triples 
    assert {person_uid, :_uid_,   person_uid}   in triples
    assert {person_uid, :age,     34}           in triples
    assert {person_uid, :name,    "Flinn"}      in triples

  end

  test "join_model_and_uids makes no changes no uid with empty map" do
    model = %Person{}
    joined = Vertex.join_model_and_uids(model, %{})
    assert  joined == model
  end

  test "join_model_and_uids will populate a uid for a default name" do
    model = %Person{}
    joined = Vertex.join_model_and_uids(model, %{"person" => "123"})
    assert model._uid_ == nil
    assert joined._uid_ == "123"
  end

  test "join_model_and_uids will populate a uid for a nested model" do
    person = %Person{}
    company = %Company{
      owner: person,
    }
    joined = Vertex.join_model_and_uids(company, %{"company" => "456", "owner" => "123"})
    assert person._uid_ == nil
    assert company._uid_ == nil
    assert joined._uid_ == "456"
    assert joined.owner._uid_ == "123"
  end
  
  test "extract_uids finds the uids in a simple model" do
    assert Vertex.extract_uids(%Person{_uid_: "132"}) == %{"person" => "132"}
  end

  test "extract_uids finds the uids in a nested model" do
    model = %Company{
      _uid_: "4567",
      owner: %Person{
        _uid_: "132"
      },
    }
    assert Vertex.extract_uids(model) == %{"company" => "4567", "owner" => "132"}
  end


end