defmodule DgraphEx.Expr.Count do
  alias DgraphEx.Expr.Count
  defstruct [
    value: nil
  ]
  
  defmacro __using__(_) do
    quote do
      def count(value) when is_atom(value) do
        %DgraphEx.Expr.Count{value: value}
      end
    end
  end

  def render(%Count{value: value}) do
    "count(#{value})"
  end
end