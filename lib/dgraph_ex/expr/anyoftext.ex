defmodule DgraphEx.Expr.Anyoftext do
  alias DgraphEx.Expr.Anyoftext
  alias DgraphEx.Util

  defstruct [
    label: nil,
    value: nil,
  ]

  defmacro __using__(_) do
    quote do
      def anyoftext(label, value) when is_atom(label) and is_binary(value) do
        DgraphEx.Expr.Anyoftext.new(label, value)
      end
    end
  end

  def new(label, value) when is_atom(label) and is_binary(value) do
    %DgraphEx.Expr.Anyoftext{
      label:  label,
      value:  value,
    }
  end

  def render(%Anyoftext{label: label, value: value}) when is_atom(label) and is_binary(value) do
    {:ok, literal_value} = Util.as_literal(value, :string)
    "anyoftext("<>Util.as_rendered(label)<>", "<>literal_value<>")"
  end

end