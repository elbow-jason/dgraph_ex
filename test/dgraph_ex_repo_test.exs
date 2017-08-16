defmodule DgraphEx.RepoTest do
  use ExUnit.Case
  doctest DgraphEx.Repo

  alias DgraphEx.{Repo, Vertex}

  alias DgraphEx.ModelPerson, as: Person
  alias DgraphEx.ModelCompany, as: Company

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
    assert company2.owner._uid_ != nil
    assert company2.owner._uid_ |> is_binary
    assert company2.owner.name == "Flynn"
    assert person1._uid_ == person2._uid_
  end

  # test "other Vertex models on a model are configured correctly" do
  #   company1 = Repo.insert(%Company{
  #     name: "Flim",
  #   })
  #   person1 = Repo.insert(%Person{
  #     name: "Flinn"
  #   })
  #   company2 = Map.put(company1, :owner, person1)
  #   assert company2 == %Company{
  #     _uid_: company1._uid_,
  #     name: "Flim",
  #     owner: %Person{
  #       _uid_: person1._uid_,
  #       age: nil,
  #       name: "Flinn",
  #       works_at: nil,
  #     }
  #   }
  # end

  # test "other Vertex models on a model fields are configured correctly" do
  #   company1 = Repo.insert(%Company{
  #     name: "Flim",
  #   })
  #   person1 = Repo.insert(%Person{
  #     name: "Flinn"
  #   })
  #   company2 = Map.put(company1, :owner, person1)
  #   assert company2 == %Company{
  #     _uid_: company1._uid_,
  #     name: "Flim",
  #     owner: %Person{
  #       _uid_: person1._uid_,
  #       age: nil,
  #       name: "Flinn",
  #       works_at: nil,
  #     }
  #   }
  #   assert Vertex.populate_fields(:company2, company2) == [
  #     %DgraphEx.Field{count: false, default: nil, facets: nil, index: [:exact, :terms], label: nil, model: nil,                  object: "Flim",                                                                        predicate: :name,  reverse: false, subject: :company2, type: :string,      virtual: false},
  #     %DgraphEx.Field{count: false, default: nil, facets: nil, index: nil,              label: nil, model: DgraphEx.ModelPerson, object: %DgraphEx.ModelPerson{_uid_: "0x53b", age: nil, name: "Flinn", works_at: nil}, predicate: :owner, reverse: true,  subject: :company2, type: :uid,         virtual: false},
  #     %DgraphEx.Field{count: nil,   default: nil, facets: nil, index: nil,              label: nil, model: nil,                  object: %DgraphEx.Expr.Uid{type: :literal, value: "0x53a"},                            predicate: :_uid_, reverse: nil,   subject: :company2, type: :uid_literal, virtual: nil}
  #   ]
  # end

end