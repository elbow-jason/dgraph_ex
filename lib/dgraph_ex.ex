defmodule DgraphEx do
  alias DgraphEx.{
    Query,
    Mutation,
    Util,
  }

  require DgraphEx.Vertex
  DgraphEx.Vertex.query_model()
  use DgraphEx.Field
  use DgraphEx.Expr
  use DgraphEx.Schema

  use Mutation
  use DgraphEx.Mutation.MutationSet
  use DgraphEx.Mutation.MutationDelete

  use Query
  use Query.Var
  use Query.As
  use Query.Select
  use Query.Filter
  use Query.Block
  use Query.Directive
  use Query.Groupby

  require DgraphEx.Expr.Math
  defmacro math(block) do
    quote do
      DgraphEx.Expr.Math.math(unquote(block))
    end
  end

  def into({:error, _} = err, _, _) do
    err
  end
  def into({:ok, resp}, module, key) when is_atom(key) and is_map(resp) do
    into(resp, module, key)
  end

  def into(resp, module, key) when is_map(resp) do
    resp
    |> Util.get_value(key, {:error, {:invalid_key, key}})
    |> do_into(module, key)
  end

  defp do_into({:error, _} = err, _, _) do
    err
  end
  defp do_into(items, module, key) when is_atom(module) do
    do_into(items, module.__struct__, key)
  end
  defp do_into(items, %{} = model, key) when is_list(items) do
    %{ key => Enum.map(items, fn item -> do_into(item, model) end) }
  end
  defp do_into(%{} = item, %{} = model, key) do
    %{ key => do_into(item, model) }
  end
  defp do_into(%{} = item, %{} = model) do
    Vertex.populate_model(model, item)
  end

  @doc """
  Gets the resolve result from 
  """
  @spec resolve_field(module, atom) :: {:ok, String.t} | {:ok, function} | {:error, :invalid} | {:error, :no_resolver}
  def resolve_field(module, atom) when is_atom(module) and is_atom(atom) do
    case Enum.find(module.__vertex__(:fields), fn(%DgraphEx.Field{predicate: name}) -> atom == name end) do
      nil -> 
        {:error, :invalid}
      %DgraphEx.Field {resolve: nil} ->
        {:ok, :no_resolver}
      %DgraphEx.Field {resolve: resolve} ->
        {:ok, resolve}
    end
  end
  @spec resolve_field(list, atom) :: {:ok, String.t} | {:ok, function} | {:error, :invalid} | {:error, :no_resolver}
  def resolve_field(fields, atom) when is_list(fields) and is_atom(atom) do
    case Enum.find(fields, fn(%DgraphEx.Field{predicate: name}) -> atom == name end) do
      nil -> 
        {:error, :invalid}
      %DgraphEx.Field {resolve: nil} ->
        {:error, :no_resolver}
      %DgraphEx.Field {resolve: resolve} ->
        {:ok, resolve}
    end
  end

end
