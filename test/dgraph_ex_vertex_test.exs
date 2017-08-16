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
end