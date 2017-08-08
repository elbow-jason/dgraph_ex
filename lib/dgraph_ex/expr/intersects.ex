defmodule DgraphEx.Expr.Intersects do
  alias DgraphEx.Expr.Intersects

  defstruct [
    label: nil,
    geo_json: nil,
  ]

  defmacro __using__(_) do
    quote do
      alias DgraphEx.Expr.Intersects

      def intersects(label, [ [x, y] | _] = geo_json) when is_atom(label) and is_float(x) and is_float(y) do
        Intersects.new(label, geo_json)
      end
    end
  end


  def new(label, [ [x, y] | _] = geo_json) when is_atom(label) and is_float(x) and is_float(y) do
    %Intersects{
      label: label,
      geo_json: geo_json,
    }
  end

  def render(%Intersects{label: label, geo_json: [ [x, y] | _] = geo_json }) when is_atom(label) and is_float(x) and is_float(y) do
    "intersects(#{label}, #{Poison.encode!(geo_json)})"
  end

end