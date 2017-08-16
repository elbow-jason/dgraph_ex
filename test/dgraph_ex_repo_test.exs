defmodule DgraphEx.RepoTest do
  use ExUnit.Case
  doctest DgraphEx.Repo

  alias DgraphEx.{Repo, Vertex}
  alias DgraphEx.Expr.Uid

  alias DgraphEx.ModelPerson, as: Person
  alias DgraphEx.ModelCompany, as: Company

  test "request returns the correct params" do
    company1 = Repo.insert(%Company{
      name: "Flim",
    })
    person1 = Repo.insert(%Person{
      name: "Flinn"
    })
    model = company1 |> Map.put(:owner, person1)
    assert DgraphEx.mutation()
    |> DgraphEx.set(model)
    |> DgraphEx.render
    |> Repo.request == {:ok, %{"code" => "Success", "message" => "Done", "uids" => %{}}}
  end

  test "nested models have their _uid_ fields filled in after being inserted" do
    company = Repo.insert(%Company{
      name: "Flim",
      owner: %Person{
        name: "Flam"
      }
    })

    assert is_binary(company._uid_)
    assert is_binary(company.owner._uid_)
  end

  test "models have their _uid_ fields filled in after being inserted" do
    company = Repo.insert(%Company{
      name: "Flim",
    })
  
    assert is_binary(company._uid_)
  end

  test "models can be inserted and then updated" do
    company1 = Repo.insert(%Company{
      name: "Flim",
    })

    company2 =
      company1
      |> Map.put(:name, "Flam")
      |> Repo.update

    assert is_binary(company1._uid_)
    assert company1.name == "Flim"
    assert company2.name == "Flam"
    assert company1._uid_ == company2._uid_
  end

  test "other Vertex models on a model are inserted and return with uids if they are new" do
    company1 = Repo.insert(%Company{
      name: "Flim",
    })
    company2 = Repo.update(%{ company1 | owner: %Person{
      name: "Flynn"
    }})
    assert company1._uid_ == company2._uid_
    assert company1.name == "Flim"
    assert company2.name == "Flim"
    assert company1.owner == nil
    assert company2.owner != nil
    assert company2.owner.__struct__ == Person
    assert company2.owner._uid_ != nil
    assert company2.owner._uid_ |> is_binary
    assert company2.owner.name == "Flynn"
  end

  test "other Vertex models on a model are updated and return with uids" do
    company1 = Repo.insert(%Company{
      name: "Flim",
    })
    person1 = Repo.insert(%Person{
      name: "Flinn"
    })

    company2 = Repo.update(%{ company1 | owner: person1 |> Map.put(:name, "Flynn")})

    person2 = company2.owner
    assert company1._uid_ == company2._uid_
    assert company1.name == "Flim"
    assert company2.name == "Flim"
    assert company1.owner == nil
    assert company2.owner != nil
    assert company2.owner.__struct__ == Person
    assert person2._uid_ == person1._uid_
    assert company2.owner._uid_ |> is_binary
    assert company2.owner.name == "Flynn"
    assert person1._uid_ == person2._uid_
  end

  test "other Vertex models on a model are configured correctly" do
    company1 = Repo.insert(%Company{
      name: "Flim",
    })
    person1 = Repo.insert(%Person{
      name: "Flinn"
    })
    company2 = Map.put(company1, :owner, person1)
    assert company2 == %Company{
      _uid_: company1._uid_,
      name: "Flim",
      owner: %Person{
        _uid_: person1._uid_,
        age: nil,
        name: "Flinn",
        works_at: nil,
      }
    }
  end

  test "other Vertex models on a model fields are configured correctly" do
    company1 = Repo.insert(%Company{
      name: "Flim",
    })
    person1 = Repo.insert(%Person{
      name: "Flinn"
    })

    company_uid = company1._uid_ |> Uid.new |> Uid.as_literal
    person_uid  = person1._uid_  |> Uid.new |> Uid.as_literal

    company2 = Map.put(company1, :owner, person1)

    assert company2 == %Company{
      _uid_: company_uid.value,
      name: "Flim",
      owner: %Person{
        _uid_: person_uid.value,
        age: nil,
        name: "Flinn",
        works_at: nil,
      }
    }
    triples = 
      Vertex.populate_fields(:company, company2)
      |> Enum.map(fn f -> {f.subject, f.predicate, f.object} end)
  
    assert {:company,     :_uid_,  company_uid}     in triples
    assert {:company,     :name,   "Flim"}          in triples
    assert {:company,     :owner,  person_uid}      in triples
    assert {person_uid,   :name,   "Flinn"}         in triples
    assert {person_uid,   :_uid_,  person_uid}      in triples
  end

end