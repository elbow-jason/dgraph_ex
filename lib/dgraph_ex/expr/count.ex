defmodule DgraphEx.Expr.Count do
  alias DgraphEx.Expr.Count
  defstruct [
    value: nil,
    extras: [],
  ]
  
  defmacro __using__(_) do
    quote do
      alias DgraphEx.Expr.Count
      def count(value) do
        Count.new(value)
      end
      def count(value, extras) do
        Count.new(value, extras)
      end
    end
  end

  def new(value) when is_atom(value) do
    %Count{value: value}
  end
  def new(value, %{__struct__: _} = model) do
    new(value, [model])
  end
  def new(value, extras) when is_list(extras) when is_atom(value) do
    %Count{value: value, extras: extras}
  end


  def render(%Count{value: v, extras: []}) do
    "count(#{v})"
  end
  def render(%Count{value: v, extras: extras}) when is_list(extras) do
    "count(#{v} " <> render_extras(extras) <> ")"
  end
  defp render_extras(extras) do
    extras
    |> Enum.map(fn %{__struct__: module} = model ->
      module.render(model)
    end)
    |> Enum.join(" ")
  end
  
end