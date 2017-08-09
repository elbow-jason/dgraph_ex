defmodule DgraphEx.Repo do
  alias DgraphEx.{Query, Vertex}

  def request(%Query{} = q) do
    q
    |> DgraphEx.assemble
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