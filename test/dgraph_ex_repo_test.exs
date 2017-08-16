defmodule DgraphEx.RepoTest do
  use ExUnit.Case
  doctest DgraphEx.Repo

  alias DgraphEx.Repo

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

end