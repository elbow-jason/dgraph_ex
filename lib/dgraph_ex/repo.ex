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
        join_model_and_uids(model, uids)
      _ ->
        resp
    end
  end

  defp join_model_and_uids(%{__struct__: _ } = model, uids, label \\ nil) do
    uid = Map.get(uids, label_string(model, label))
    model
    |> Map.from_struct
    |> Enum.reduce(model, fn
      ({key, %{__struct__: _} = submodel}, acc_model) ->
        Map.put(acc_model, key, join_model_and_uids(submodel, uids, key))
      (_, acc_model) ->
        acc_model
    end)
    |> Map.put(:_uid_, uid)
  end

  defp label_string(_, label) when not is_nil(label) do
    to_string(label)
  end
  defp label_string(%{__struct__: module}, nil) do
    module.__vertex__(:default_label) |> to_string
  end
  

end