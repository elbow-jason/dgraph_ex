defmodule DgraphEx.Expr.Eq do
  alias DgraphEx.Expr.Eq
  alias DgraphEx.Util

  defstruct [
    label: nil,
    value: nil,
    type: nil,
  ]

  defmacro __using__(_) do
    quote do
      def eq(label, value, type) when is_atom(label) do
        %DgraphEx.Expr.Eq{
          label:  label,
          value:  value,
          type:   type,
        }
      end
    end
  end


  def render(%Eq{label: label, value: value, type: type}) when is_atom(label) and is_atom(type) do
    {:ok, literal_value} = Util.as_literal(value, type)
    "eq("<>Util.as_rendered(label)<>", "<>literal_value<>")"
  end

end