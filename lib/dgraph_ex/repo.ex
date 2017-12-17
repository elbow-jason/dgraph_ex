defmodule DgraphEx.Repo do

  def alter([%DgraphEx.Field{} | _] = fields) do
    DgraphEx.Client.send(data: DgraphEx.Alter.new(fields))
  end
  def alter(module) when is_atom(module) do
    if !DgraphEx.Vertex.is_model?(module) do
      raise %ArgumentError{
        message: "DgraphEx.Repo.alter/1 only responds to Vertex models. #{module} does not use DgraphEx.Vertex"
      }
    end
    data =
      module.__vertex__(:fields)
      |> DgraphEx.Alter.new()
    DgraphEx.Client.send(data: data)
  end

  def mutate(%DgraphEx.Set{} = set) do
    DgraphEx.Client.send(data: set)
  end

  def query(kwargs) when is_list(kwargs) do
    DgraphEx.Client.send(data: DgraphEx.Kwargs.parse(kwargs), path: "/query")
  end

end

  # alias DgraphEx.{
  #   Query,
  #   Vertex,
  #   Set,
  #   Changeset,
  #   Alter,
  # }
  # alias DgraphEx.Expr.Uid

  # @allowed_modules [
  #   Query,
  #   Set,
  #   Alter,
  # ]

  # def request(%module{} = model, opts \\ []) when module in @allowed_modules and is_list(opts) do
  #   model
  #   |> DgraphEx.render
  #   |> send_request(module, opts)
  # end
  # defp send_request(body, module, opts) when is_atom(module) do
  #   {path, opts} = Keyword.pop(opts, :path, module.path())
  #   send_request(body, path, opts)
  # end
  # defp send_request(body, path, opts) when is_binary(path) do
  #   [body: body, path: path]
  #   |> Kernel.++(opts)
  #   # |> IO.inspect(label: "request params")
  #   |> DgraphEx.Client.send()
  # end

  # def get(module, uid) when is_binary(uid) and is_atom(module) do
  #   DgraphEx.query()
  #   |> DgraphEx.func(:get_by_uid, DgraphEx.uid(uid))
  #   |> DgraphEx.select(module.__struct__)
  #   |> request
  #   |> case do
  #     {:ok, %{"get_by_uid" => []}} ->
  #       nil
  #     {:ok, %{"get_by_uid" => [%{"_uid_" => _} = found]}} when map_size(found) == 1 ->
  #       nil
  #     {:ok, %{"get_by_uid" => [found]}} ->
  #       Vertex.populate_model(module.__struct__, found)
  #     err ->
  #       err
  #   end
  # end

  # def insert(%Changeset{} = changeset) do
  #   case Changeset.uncast(changeset) do
  #     {:ok, model} ->
  #       insert(model)
  #     err ->
  #       err
  #   end
  # end
  # def insert(%_{_uid_: nil} = model) do
  #   if !Vertex.is_model?(model) do
  #     raise_vertex_models_only()
  #   end
  #   prev_uids = Vertex.extract_uids(model)
  #   model
  #   |> DgraphEx.set()
  #   |> request
  #   |> case do
  #     {:ok, %{"code" => "Success", "message" => "Done", "uids" => uids}} ->
  #       Vertex.join_model_and_uids(model, Map.merge(prev_uids, uids))
  #     resp ->
  #       resp
  #   end
  # end

  # def update(%Changeset{} = changeset) do
  #   case Changeset.uncast(changeset) do
  #     {:ok, model} ->
  #       update(model)
  #     err ->
  #       err
  #   end
  # end
  # def update(%module{_uid_: uid} = model) when is_binary(uid) do
  #   model
  #   |> do_update
  #   |> case do
  #     %^module{_uid_: nil} = updated ->
  #       updated
  #       |> Map.put(:_uid_, uid)
  #     %^module{} = updated ->
  #       updated
  #     error ->
  #       error
  #   end
  # end
  # def update(%_{_uid_: %Uid{value: uid}} = model) when is_binary(uid) do
  #   model
  #   |> Map.put(:_uid_, uid)
  #   |> update
  # end

  # defp do_update(model) do
  #   if !Vertex.is_model?(model) do
  #     raise_vertex_models_only()
  #   end
  #   prev_uids = Vertex.extract_uids(model)
  #   DgraphEx.mutation()
  #   |> DgraphEx.set(model)
  #   |> DgraphEx.render
  #   |> request
  #   |> case do
  #     {:ok, %{"code" => "Success", "message" => "Done", "uids" => uids}} ->
  #       Vertex.join_model_and_uids(model, Map.merge(prev_uids, uids))
  #     resp ->
  #       resp
  #   end
  # end

  # def delete(%_{_uid_: uid} = model) when is_binary(uid) do
  #   if !Vertex.is_model?(model) do
  #     raise_vertex_models_only()
  #   end
  #   prev_uids = Vertex.extract_uids(model)
  #   DgraphEx.mutation()
  #   |> DgraphEx.delete(DgraphEx.uid(uid), "*", "*")
  #   |> request
  #   |> case do
  #     {:ok, %{"code" => "Success", "message" => "Done", "uids" => uids}} ->
  #       Vertex.join_model_and_uids(model, Map.merge(prev_uids, uids))
  #     resp ->
  #       resp
  #   end
  # end

  # defp raise_vertex_models_only do
  #   raise """
  #     DgraphEx.Repo.update only accepts Vertex models.
  #   """
  # end
# end
