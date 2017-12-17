defmodule DgraphEx do
  alias DgraphEx.{
    Query,
    # Mutation,
    Util,
  }

  require DgraphEx.Vertex
  DgraphEx.Vertex.query_model()
  use DgraphEx.Field
  use DgraphEx.Expr
  # use DgraphEx.Schema

  # use Mutation
  use DgraphEx.Set
  use DgraphEx.Delete
  # use DgraphEx.Alter

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

  def thing do
    :ok
  end

end
