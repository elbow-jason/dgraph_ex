defmodule DgraphEx.RepoTest do
  use ExUnit.Case
  doctest DgraphEx.Repo

  alias DgraphEx.Repo

  # import DgraphEx
  # import TestHelpers

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

end