defmodule DgraphEx.Expr.Expand do
  alias DgraphEx.Expr.Expand

  defstruct [
    label: nil
  ]

  defmacro __using__(_) do
    quote do
      alias DgraphEx.Expr.Expand
      def expand(label) when is_atom(label) do
        Expand.new(label)
      end
    end
  end
  
  def new(label) when is_atom(label) do
    %Expand{
      label: label
    }
  end

  def render(%Expand{label: label}) when is_atom(label) do
    "expand(#{label})"
  end

end