defmodule DgraphEx.Query.Filter do
  alias DgraphEx.{Query, Field}
  alias Query.{Filter, Block}

  defstruct [
    expr: nil,
    block: nil,
  ]

  defmacro __using__(_) do
    quote do
      alias DgraphEx.Query
      def filter(a, b \\ nil, c \\ nil) do
        case {a, b, c} do
          {_, nil, nil} -> DgraphEx.Query.Filter.filter_1(a)
          {_,   _, nil} -> DgraphEx.Query.Filter.filter_2(a, b)
          _             -> DgraphEx.Query.Filter.filter_3(a, b, c)
        end
      end
    end
  end

  def new(%{__struct__: _} = expr, block) do
    %Filter{
      expr:   expr,
      block:  block,
    }
  end

  def filter_1(%{__struct__: _} = expr) do
    %Filter{
      expr:   expr,
      block:  {},
    }
  end
  def filter_2(%{__struct__: _} = expr, block) when is_tuple(block) do
    %Filter{
      expr:   expr,
      block:  block,
    }
  end
  def filter_3(%Query{} = q, %{__struct__: _} = expr, block) when is_tuple(block) do
    Query.put_sequence(q, filter_2(expr, block))
  end

  def render(%Filter{} = f) do
    "@filter(#{render_expr(f)}) " <> render_block(f)
  end

  defp render_expr(%Filter{expr: %{__struct__: module} = model}) do
    module.render(model)
  end

  defp render_block(%Filter{block: {}}) do
    ""
  end
  defp render_block(%Filter{block: block}) do
    Block.render(block)
  end

  defp interpolate(item) do
    case item do
      %{__struct__: module} = model ->
        module.render(model)
      {key, value} when is_atom(key) and is_atom(value) ->
        "#{key}: #{value}"
      {key, %{__struct__: module} = model} when is_atom(key) ->
        "#{key}: "<>module.render(model)
      x when is_binary(x) -> 
        x
        |> Field.stringify
        |> Field.wrap_quotes
      x ->
        x
        |> Field.stringify
    end
  end
end