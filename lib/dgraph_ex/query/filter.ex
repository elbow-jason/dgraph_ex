defmodule DgraphEx.Query.Filter do
  alias DgraphEx.Query.Filter

  defstruct [
    expr: nil,
  ]

  defmacro __using__(_) do
    quote do
      def filter(%{__struct__: _} = expr) do
        DgraphEx.Query.Filter.new(expr)
      end
    end
  end

  def new(%{__struct__: _} = expr) do
    %Filter{
      expr: expr
    }
  end

  def render(%Filter{} = f) do
    "@filter(#{render_expr(f)})"
  end

  defp render_expr(%Filter{expr: %{__struct__: module} = model}) do
    module.render(model)
  end
end