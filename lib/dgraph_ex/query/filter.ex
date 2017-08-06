defmodule DgraphEx.Query.Filter do
  alias DgraphEx.Query.{Filter, Block}
  alias DgraphEx.Field

  defstruct [
    expr: nil,
    block: nil,
  ]

  defmacro __using__(_) do
    quote do
      alias DgraphEx.Query
      def filter(%Query{} = q, %{__struct__: _} = expr, block) do
        Query.put_sequence(q, filter(expr, block))
      end
      def filter(%{__struct__: _} = expr, block) when is_tuple(block) do
        DgraphEx.Query.Filter.new(expr, block)
      end
    end
  end

  def new(%{__struct__: _} = expr, block) do
    %Filter{
      expr:   expr,
      block:  block,
    }
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