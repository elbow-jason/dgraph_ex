defmodule DgraphEx.Expr.Sum do
  alias DgraphEx.Expr.{Sum, Val}
  alias DgraphEx.Util

  defstruct [
    label: nil
  ]

  defmacro __using__(_) do
    quote do
      def sum(label) do
        DgraphEx.Expr.Sum.new(label)
      end
    end
  end

  def new(%{__struct__: Val} = label) do
    %Sum{label: label}
  end
  def new(label) when is_atom(label) do
    %Sum{label: label}
  end

  def render(%Sum{label: %{__struct__: module} = model}) do
    model
    |> module.render
    |> do_render
  end
  def render(%Sum{label: label}) do
    label
    |> Util.as_rendered
    |> do_render
  end

  defp do_render(rendered_label) do
    "sum("<>rendered_label<>")"
  end

end