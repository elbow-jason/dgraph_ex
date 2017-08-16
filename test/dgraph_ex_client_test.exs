defmodule DgraphEx.ClientTest do
  use ExUnit.Case

  doctest DgraphEx.Client

  alias DgraphEx.Client

  
  
  test "" do
    query = """
      mutation {
        set {
          _:company <name>  "TurfBytes"^^<xs:string> .
          _:company <owner> _:owner .
          _:owner   <name>  "Jason"^^<xs:string> .
        }
      }
    """

    {:ok, response} = Client.send(query)
    assert response["code"] == "Success"
    assert response["message"] == "Done"
    %{"company" => company_uid, "owner" => owner_uid} = response["uids"]
    assert is_binary(company_uid)
    assert is_binary(owner_uid)
  end
end