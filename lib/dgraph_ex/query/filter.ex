defmodule DgraphEx.Query.Filter do
  alias DgraphEx.{Query}
  alias Query.{Filter, Block}
  alias DgraphEx.Expr.Uid

  defstruct [
    expr: nil,
    block: nil,
  ]

  defmacro __using__(_) do
    quote do
      def filter(a, b \\ nil, c \\ nil) do
        DgraphEx.Query.Filter.new(a, b, c)
      end
    end
  end

  #remove new here.
  def new(a, b \\ nil, c \\ nil) do
    case {a, b, c} do
      {_, nil, nil} -> DgraphEx.Query.Filter.filter_1(a)
      {_,   _, nil} -> DgraphEx.Query.Filter.filter_2(a, b)
      _             -> DgraphEx.Query.Filter.filter_3(a, b, c)
    end
  end

  def filter_1(%{__struct__: _} = expr) do
    %Filter{
      expr:   prepare_expr(expr),
      block:  {},
    }
  end
  def filter_2(%Query{} = q, %{__struct__: _} = expr) do
    filter_3(q, expr, {})
  end
  def filter_2(%{__struct__: _} = expr, block) when is_tuple(block) do
    %Filter{
      expr:   prepare_expr(expr),
      block:  block,
    }
  end
  def filter_3(%Query{} = q, %{__struct__: _} = expr, block) when is_tuple(block) do
    Query.put_sequence(q, filter_2(expr, block))
  end

  def render(%Filter{} = f) do
    [
      "@filter(#{render_expr(f)})",
      render_block(f),
    ]
    |> Enum.filter(fn
      "" -> nil
      item -> item
    end)
    |> Enum.join(" ")
  end

  defp render_expr(%Filter{expr: %{__struct__: module} = model}) do
    module.render(model)
  end

  defp render_block(%Filter{block: nil}) do
    ""
  end
  defp render_block(%Filter{block: {}}) do
    ""
  end
  defp render_block(%Filter{block: block}) do
    Block.render(block)
  end

  def prepare_expr(expr) do
    case expr do
      %Uid{} -> expr |> Uid.as_expression
      _ -> expr
    end
  end

end