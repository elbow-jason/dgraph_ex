defmodule DgraphEx.Repo do
  alias DgraphEx.{Query, Mutation, Vertex}

  @allowed_modules [
    Query,
    Mutation,
  ]

  def request(%{__struct__: module} = model) when module in @allowed_modules do
    model
    |> DgraphEx.render
    |> DgraphEx.Client.send
  end

  def insert(%{__struct__: _} = model) do
    resp =
      DgraphEx.mutation()
      |> DgraphEx.set(model)
      |> request
    case resp do
      {:ok, %{"code" => "Success", "message" => "Done", "uids" => uids}} ->
        Vertex.join_model_and_uids(model, uids)
      _ ->
        resp
    end
  end

end