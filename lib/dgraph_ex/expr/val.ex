defmodule DgraphEx.Expr.Val do
  alias DgraphEx.Expr.Val
  alias DgraphEx.Util

  defstruct [
    label: nil
  ]

  defmacro __using__(_) do
    quote do
      def val(label) do
        DgraphEx.Expr.Val.new(label)
      end
    end
  end

  def new(label) when is_atom(label) do
    %Val{label: label}
  end

  def render(%Val{label: label}) do
    "val("<>(label |> Util.as_rendered)<>")"
  end

end