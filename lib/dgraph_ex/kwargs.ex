defmodule DgraphEx.Kwargs do
  alias DgraphEx.{Query, Mutation}
  alias Query.{Block}

  #as per @srh on dgraph slack (there may be more than these) v0.8.0
  @executors ~w(
    func
    orderasc
    orderdesc
    first
    after
    offset
  )a

  def query(kwargs) when is_list(kwargs) do
    do_query(%Query{}, kwargs)
  end

  defp do_query(q, []) do
    q
  end
  defp do_query(q, [ %Query{} = sub_q | rest ]) do
    q
    |> Query.merge(sub_q)
    |> do_query(rest)
  end
  defp do_query(q, [ {:as, key}, {:get, %Query{} = get_q} | rest ]) when is_atom(key) do
    q
    |> DgraphEx.as(key)
    |> Query.merge(get_q)
    |> do_query(rest)
  end
  # as => key => get => func
  defp do_query(q, [ {:as, key}, {:get, :var}, {:func, _} = fun | rest ]) when is_atom(key) do
    q
    |> DgraphEx.as(key)
    |> do_query([ {:get, :var}, fun | rest])
  end
  defp do_query(q, [ {:as, key}, {:func, _} = fun | rest ]) when is_atom(key) do
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

  defp do_query(q, [ {:get, label}, {:func, %{__struct__: _} = expr} | rest ]) do
    q
    |> DgraphEx.block(label, [func: expr])
    |> do_query(rest)
  end
  defp do_query(%Query{sequence: [%Block{} = b | rest_seq ]} = q, [ {executor, expr} | rest ]) when executor in @executors do
    %{ q | sequence: [ Block.put_kwarg(b, executor, expr) | rest_seq ] }
    |> do_query(rest)
  end
  defp do_query(q, [ { executor, expr} | rest ]) when executor in @executors do
    q
    |> DgraphEx.block([{executor, expr}])
    |> do_query(rest)
  end
  defp do_query(q, [ {:filter, %{__struct__: _} = expr} | rest]) do
    q
    |> DgraphEx.filter(expr)
    |> do_query(rest)
  end
  defp do_query(q, [ {:select, block} | rest ]) when is_tuple(block) do
    q
    |> DgraphEx.select(block)
    |> do_query(rest)
  end
  defp do_query(q, [ {:ignorereflex, true} | rest ]) do
    q
    |> DgraphEx.ignorereflex()
    |> do_query(rest)
  end
  defp do_query(q, [ {:cascade, true} | rest ]) do
    q
    |> DgraphEx.cascade()
    |> do_query(rest)
  end
  defp do_query(q, [ {:normalize, true} | rest ]) do
    q
    |> DgraphEx.normalize()
    |> do_query(rest)
  end
  defp do_query(q, [ {:directives, directives} | rest ]) when is_list(directives) do
    Enum.reduce(directives, q, fn
      (:ignorereflex, q_acc) -> DgraphEx.ignorereflex(q_acc)
      (:normalize,    q_acc) -> DgraphEx.normalize(q_acc)
      (:cascade,      q_acc) -> DgraphEx.cascade(q_acc)
    end)
    |> do_query(rest)
  end
  defp do_query(q, [ {:groupby, pred} | rest ]) when is_atom(pred) do
    q
    |> DgraphEx.groupby(pred)
    |> do_query(rest)
  end
  defp do_query(q, [ {:count, item} | rest ]) do
    q
    |> Query.put_sequence(DgraphEx.count(item))
    |> do_query(rest)
  end
  defp do_query(q, [ {:has, value} | rest ]) do
    q
    |> Query.put_sequence(DgraphEx.has(value))
    |> do_query(rest)
  end

  # def mutation(kwargs) when is_list(kwargs) do
  #   do_mutation(%Mutation{}, kwargs)
  # end

  # def do_mutation(m, []) do
  #   m
  # end
  # def do_mutation(m, [{:set, block} | rest ]) do
  #   m
  #   |> DgraphEx.set(block)
  #   |> do_mutation(rest)
  # end
  # def do_mutation(m, [{:schema, module} | rest ]) do
  #   m
  #   |> DgraphEx.schema(module)
  #   |> do_mutation(rest)
  # end
  # def do_mutation(m, [{:delete, item} | rest ]) do
  #   m
  #   |> DgraphEx.delete(item)
  #   |> do_mutation(rest)
  # end


end