defmodule DgraphEx.Query.Filter do
  alias DgraphEx.{Query}
  alias Query.{Filter}
  alias DgraphEx.Expr.Uid

  defstruct [
    expr: nil,
  ]

  @connectors [
    :and,
    :or,
    :not,
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

  def render(%Filter{expr: expr}) do
    "@filter#{render_expr(expr)}"
  end

  defp render_single(%{__struct__: module} = model) do
    module.render(model)
  end
  defp render_single(connector) when connector in @connectors do
    render_connector(connector)
  end
  defp render_single(list) when is_list(list) do
    render_expr(list)
  end
  
  defp render_expr(exprs) when is_list(exprs) do
    exprs
    # |> Enum.reverse
    |> Enum.map(&render_single/1)
    |> Enum.join(" ")
    |> wrap_parens
  end
  defp render_expr(item) do
    render_expr([item])
  end

  defp wrap_parens(item) do
    "("<>item<>")"
  end

  defp render_connector(:and), do: "AND"
  defp render_connector(:or),  do: "OR"
  defp render_connector(:not), do: "NOT"

  defp prepare_expr(expr) do
    case expr do
      %Uid{} -> expr |> Uid.as_expression
      _ -> expr
    end
  end

end