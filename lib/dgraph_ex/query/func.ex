defmodule DgraphEx.Query.Func do
  alias DgraphEx.{Field, Query, Expr}
  alias Query.{Func, Block}
  alias Expr.{Uid}

  defstruct [
    name:   nil,
    expr:   nil,
    block:  {},
  ]

  defmacro __using__(_) do
    quote do
      def func(one, two, three \\ nil, four \\ nil) do
        alias DgraphEx.Query
        case {one, two, three, four} do
          {%Query{}, _, %{__struct__: _}, block} when is_nil(block) or is_tuple(block) ->
            Query.Func.func_4(one, two, three, four)
          {_, _, _, nil} ->
            Query.Func.func_3(one, two, three)
        end
      end
    end
  end

  def func_4(q, name, expr, nil) do
    func_4(q, name, expr, {})
  end
  def func_4(%Query{} = q, name, %{__struct__: _} = expr, block) when is_tuple(block) do
    Query.put_sequence(q ,%Query.Func{
      name:   name,
      expr:   Query.Func.prepare_expr(expr),
      block:  block,
    })
  end
  def func_3(name, expr, nil) do
    func_3(name, expr, {})
  end
  def func_3(name, %{__struct__: _} = expr, block) when is_tuple(block) do
    %Query.Func{
      name:   name,
      expr:   Query.Func.prepare_expr(expr),
      block:  block,
    }
  end

  def render(%Func{} = f) do
    "#{f.name}(func: #{render_expr(f)}) " <> render_block(f)
  end

  defp render_block(%Func{block: {}}) do
    ""
  end
  defp render_block(%Func{block: block}) do
    Block.render(block)
  end

  defp render_expr(%Func{expr: %{__struct__: module} = model}) do
    module.render(model)
  end

  def prepare_expr(expr) do
    case expr do
      %Uid{} -> expr |> Uid.as_expression
      _ -> expr
    end
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