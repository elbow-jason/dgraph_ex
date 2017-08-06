defmodule DgraphEx.Query.Func do
  alias DgraphEx.{Field}
  alias DgraphEx.Query.{Func}
  alias DgraphEx.Expr.{Uid}

  defstruct [
    name:   nil,
    expr:   nil,
    block:  [],
  ]

  defmacro __using__(_) do
    quote do
      alias DgraphEx.Query
      def func(%Query{} = q, name, expr, block) do
        q
        |> Query.put_sequence(%Query.Func{
          name:   name,
          expr:   Query.Func.prepare_expr(expr),
          block:  block,
        })
      end
    end
  end

  

  def render(%Func{} = f) do
    "#{f.name}(func: #{render_expr(f)}) {\n" <> render_block(f) <> "\n}\n"
  end

  defp render_block(%Func{block: block}) do
    block
    |> Enum.map(&interpolate/1)
    |> Enum.join("\n")
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