defmodule DgraphEx.Expr.Alloftext do
  alias DgraphEx.Expr.Alloftext
  alias DgraphEx.Util

  defstruct [
    label: nil,
    value: nil,
  ]

  defmacro __using__(_) do
    quote do
      def alloftext(label, value) when is_atom(label) and is_binary(value) do
        DgraphEx.Expr.Alloftext.new(label, value)
      end
    end
  end

  def new(label, value) when is_atom(label) and is_binary(value) do
    %DgraphEx.Expr.Alloftext{
      label:  label,
      value:  value,
    }
  end

  def render(%Alloftext{label: label, value: value}) when is_atom(label) and is_binary(value) do
    {:ok, literal_value} = Util.as_literal(value, :string)
    "alloftext("<>Util.as_rendered(label)<>", "<>literal_value<>")"
  end

end