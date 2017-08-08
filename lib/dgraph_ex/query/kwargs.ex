defmodule DgraphEx.Query.Kwargs do
  alias DgraphEx.Query
  alias Query.{As, Block}

  #as per @srh on dgraph slack (there may be more than these) v0.8.0
  @executors ~w(func orderasc orderdesc first after offset)a

  def query(kwargs) when is_list(kwargs) do
    do_query(%Query{}, kwargs)
  end

  defp do_query(q, []) do
    q
  end
  # as => key => get => func
  defp do_query(q, [{:as, key}, {:get, :var}, {:func, _} = fun | rest ]) when is_atom(key) do
    q
    |> DgraphEx.as(key)
    |> do_query([ {:get, :var}, fun | rest])
  end
  defp do_query(q, [{:as, key}, {:func, _} = fun | rest ]) when is_atom(key) do
    q
    |> DgraphEx.as(key)
    |> do_query([{:get, :var}, fun | rest ])
  end
  # invalid :as follower
  defp do_query(_, [{k, v} | _]) when (k == :as or v == :as) and (is_atom(k) and is_atom(v)) do
    raise %ArgumentError{
      message: "When building a query :as can only be followed by `get: :var` or `func: <expr>` keywords"
    }
  end
  # invalid :as key config
  defp do_query(_, [{k, v} | _]) when (k == :as or v == :as) do
    raise %ArgumentError{
      message: "When building a query with :as the counterpart can only be an atom"
    }
  end

  defp do_query(q, [{:get, label}, {:func, %{__struct__: _} = expr} | rest ]) do
    q
    |> DgraphEx.block(label, [func: expr])
    |> do_query(rest)
  end
  defp do_query(%Query{sequence: [%Block{} = b | rest_seq ]} = q, [ {executor, expr} | rest ]) when executor in @executors do
    %{ q | sequence: [ Block.put_kwarg(b, executor, expr) | rest_seq ] }
    |> do_query(rest)
  end

  defp do_query(q, [{:filter, %{__struct__: _} = expr} | rest]) do
    q
    |> DgraphEx.filter(expr)
    |> do_query(rest)
  end
  defp do_query(q, [{:select, block} | rest ]) when is_tuple(block) do
    q
    |> DgraphEx.select(block)
    |> do_query(rest)
  end
  # defp do_query(q, [{:ignorereflex, true} | rest ]) do
  #   q
  #   |> 
  # end


end