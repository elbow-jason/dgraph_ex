defmodule DgraphEx.Query.Filter do
  alias DgraphEx.{Query}
  alias Query.{Filter, Block}
  alias DgraphEx.Expr.Uid

  defstruct [
    expr: nil,
  ]

  defmacro __using__(_) do
    quote do
      alias DgraphEx.Query.Filter
      def filter(%Query{} = q, expr) do
        Query.put_sequence(q, Filter.new(expr))
      end
      def filter(%{__struct__: _} = expr) do
        Filter.new(expr)
      end
      def filter(expr) when is_list(expr) do
        Filter.new(expr)
      end
    end
  end

  def new(%{__struct__: _} = expr) do
    %Filter{
      expr: prepare_expr(expr)
    }
  end
  def new(expr) when is_list(expr) do
    %Filter{
      expr: prepare_expr(expr),
    }
  end

  def put_sequence(%Query{} = q, %Filter{} = f) do
    Query.put_sequence(q, f)
  end
  def put_sequence(%Query{} = q, expr) do
    put_sequence(q, new(expr))
  end

  def render(%Filter{expr: expr} = f) do
    "@filter(#{render_expr(expr)})"
  end

  defp render_expr(%{__struct__: module} = model) do
    module.render(model)
  end

  def prepare_expr(expr) do
    case expr do
      %Uid{} -> expr |> Uid.as_expression
      _ -> expr
    end
  end

end