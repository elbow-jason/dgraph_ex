defmodule DgraphEx.Repo do
  alias DgraphEx.{
    Query,
    Vertex,
    Mutation,
    Changeset,
  }
  alias DgraphEx.Expr.Uid

  @allowed_modules [
    Query,
    Mutation,
  ]

  def request(%{__struct__: module} = model) when module in @allowed_modules do
    model
    |> DgraphEx.render
    |> request
  end

  def request(binary) when is_binary(binary) do
    DgraphEx.Client.send(binary)
  end

  def get(module, uid) when is_binary(uid) and is_atom(module) do
    DgraphEx.query()
    |> DgraphEx.func(:get_by_uid, DgraphEx.uid(uid))
    |> DgraphEx.select(module.__struct__)
    |> request
    |> case do
      {:ok, %{"get_by_uid" => []}} ->
        nil
      {:ok, %{"get_by_uid" => [%{"_uid_" => _} = found]}} when map_size(found) == 1 ->
        nil
      {:ok, %{"get_by_uid" => [found]}} ->
        Vertex.populate_model(module.__struct__, found)
      err ->
        err
    end
  end

  def insert(%Changeset{} = changeset) do
    case Changeset.uncast(changeset) do
      {:ok, model} ->
        insert(model)
      err ->
        err
    end
  end
  def insert(%{__struct__: _, _uid_: nil} = model) do
    if !Vertex.is_model?(model) do
      raise_vertex_models_only()
    end
    prev_uids = Vertex.extract_uids(model)
    DgraphEx.mutation()
    |> DgraphEx.set(model)
    |> request
    |> case do
      {:ok, %{"code" => "Success", "message" => "Done", "uids" => uids}} ->
        Vertex.join_model_and_uids(model, Map.merge(prev_uids, uids))
      resp ->
        resp
    end
  end

  def update(%{__struct__: module, _uid_: uid} = model) when is_binary(uid) do
    model
    |> do_update
    |> case do
      %{__struct__: ^module, _uid_: nil} = updated ->
        updated
        |> Map.put(:_uid_, uid)
      %{__struct__: ^module} = updated ->
        updated
      error ->
        error
    end
  end
  def update(%{__struct__: _, _uid_: %Uid{value: uid}} = model) when is_binary(uid) do
    model
    |> Map.put(:_uid_, uid)
    |> update
  end

  defp do_update(model) do
    if !Vertex.is_model?(model) do
      raise_vertex_models_only()
    end
    prev_uids = Vertex.extract_uids(model)
    DgraphEx.mutation()
    |> DgraphEx.set(model)
    |> DgraphEx.render
    |> request
    |> case do
      {:ok, %{"code" => "Success", "message" => "Done", "uids" => uids}} ->
        Vertex.join_model_and_uids(model, Map.merge(prev_uids, uids))
      resp ->
        resp
    end
  end

  def delete(%{__struct__: _, _uid_: uid} = model) when is_binary(uid) do
    if !Vertex.is_model?(model) do
      raise_vertex_models_only()
    end
    prev_uids = Vertex.extract_uids(model)
    DgraphEx.mutation()
    |> DgraphEx.delete(DgraphEx.uid(uid), "*", "*")
    |> request
    |> case do
      {:ok, %{"code" => "Success", "message" => "Done", "uids" => uids}} ->
        Vertex.join_model_and_uids(model, Map.merge(prev_uids, uids))
      resp ->
        resp
    end
  end


  defp raise_vertex_models_only do
    raise """
      DgraphEx.Repo.update only accepts Vertex models.
    """
  end
end