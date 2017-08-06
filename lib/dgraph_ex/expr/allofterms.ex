defmodule DgraphEx.Expr.Allofterms do
  alias DgraphEx.Expr.Allofterms
  alias DgraphEx.Util

  defstruct [
    label: nil,
    value: nil,
  ]

  defmacro __using__(_) do
    quote do
      def allofterms(label, value) when is_atom(label) and is_binary(value) do
        DgraphEx.Expr.Allofterms.new(label, value)
      end
    end
  end

  def new(label, value) when is_atom(label) and is_binary(value) do
    %DgraphEx.Expr.Allofterms{
      label:  label,
      value:  value,
    }
  end

  def render(%Allofterms{label: label, value: value}) when is_atom(label) and is_binary(value) do
    {:ok, literal_value} = Util.as_literal(value, :string)
    "allofterms("<>Util.as_rendered(label)<>", "<>literal_value<>")"
  end

end