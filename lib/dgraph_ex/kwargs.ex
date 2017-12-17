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

  def parse(kwargs) when is_list(kwargs) do
    do_parse(%Query{}, kwargs)
  end

  defp do_parse(q, []) do
    q
  end
  defp do_parse(q, [{:set, %_{} = model} | rest]) do
    model
    |> DgraphEx.set
    |> do_parse(rest)
  end
  defp do_parse(q, [ %Query{} = sub_q | rest ]) do
    q
    |> Query.merge(sub_q)
    |> do_parse(rest)
  end
  defp do_parse(q, [ {:as, subject}, {:set, %_{} = model} | rest ]) do
    DgraphEx.set(subject, model)
    |> do_parse(rest)
  end
  defp do_parse(q, [ {:as, key}, {:get, %Query{} = get_q} | rest ]) when is_atom(key) do
    q
    |> DgraphEx.as(key)
    |> Query.merge(get_q)
    |> do_parse(rest)
  end
  # as => key => get => func
  defp do_parse(q, [ {:as, key}, {:get, :var}, {:func, _} = fun | rest ]) when is_atom(key) do
    q
    |> DgraphEx.as(key)
    |> do_parse([ {:get, :var}, fun | rest])
  end
  defp do_parse(q, [ {:as, key}, {:func, _} = fun | rest ]) when is_atom(key) do
    q
    |> DgraphEx.as(key)
    |> do_parse([{:get, :var}, fun | rest ])
  end
  # invalid :as follower
  defp do_parse(_, [{k, v} | _]) when (k == :as or v == :as) and (is_atom(k) and is_atom(v)) do
    raise %ArgumentError{
      message: "When building a query :as can only be followed by `get: :var` or `func: <expr>` keywords"
    }
  end
  # invalid :as key config
  defp do_parse(_, [{k, v} | _]) when (k == :as or v == :as) do
    raise %ArgumentError{
      message: "When building a query with :as the counterpart can only be an atom"
    }
  end

  defp do_parse(q, [ {:get, label}, {:func, %{__struct__: _} = expr} | rest ]) do
    q
    |> DgraphEx.block(label, [func: expr])
    |> do_parse(rest)
  end
  defp do_parse(%Query{sequence: [%Block{} = b | rest_seq ]} = q, [ {executor, expr} | rest ]) when executor in @executors do
    %{ q | sequence: [ Block.put_kwarg(b, executor, expr) | rest_seq ] }
    |> do_parse(rest)
  end
  defp do_parse(q, [ { executor, expr} | rest ]) when executor in @executors do
    q
    |> DgraphEx.block([{executor, expr}])
    |> do_parse(rest)
  end
  defp do_parse(q, [ {:filter, %{__struct__: _} = expr} | rest]) do
    q
    |> DgraphEx.filter(expr)
    |> do_parse(rest)
  end
  defp do_parse(q, [ {:select, block} | rest ]) when is_tuple(block) do
    q
    |> DgraphEx.select(block)
    |> do_parse(rest)
  end
  defp do_parse(q, [ {:ignorereflex, true} | rest ]) do
    q
    |> DgraphEx.ignorereflex()
    |> do_parse(rest)
  end
  defp do_parse(q, [ {:cascade, true} | rest ]) do
    q
    |> DgraphEx.cascade()
    |> do_parse(rest)
  end
  defp do_parse(q, [ {:normalize, true} | rest ]) do
    q
    |> DgraphEx.normalize()
    |> do_parse(rest)
  end
  defp do_parse(q, [ {:directives, directives} | rest ]) when is_list(directives) do
    Enum.reduce(directives, q, fn
      (:ignorereflex, q_acc) -> DgraphEx.ignorereflex(q_acc)
      (:normalize,    q_acc) -> DgraphEx.normalize(q_acc)
      (:cascade,      q_acc) -> DgraphEx.cascade(q_acc)
    end)
    |> do_parse(rest)
  end
  defp do_parse(q, [ {:groupby, pred} | rest ]) when is_atom(pred) do
    q
    |> DgraphEx.groupby(pred)
    |> do_parse(rest)
  end
  defp do_parse(q, [ {:count, item} | rest ]) do
    q
    |> Query.put_sequence(DgraphEx.count(item))
    |> do_parse(rest)
  end
  defp do_parse(q, [ {:has, value} | rest ]) do
    q
    |> Query.put_sequence(DgraphEx.has(value))
    |> do_parse(rest)
  end
  defp do_parse(q, [{:delete, item} | rest ]) do
    q
    |> DgraphEx.delete(item)
    |> do_parse(rest)
  end


end