defmodule DgraphEx.Expr.Within do
  alias DgraphEx.Expr.Within

  defstruct [
    label: nil,
    geo_json: nil,
  ]

  defmacro __using__(_) do
    quote do
      alias DgraphEx.Expr.Within

      def within(label, [[ [x, y] | _] |_] = geo_json) when is_atom(label) and is_float(x) and is_float(y) do
        Within.new(label, geo_json)
      end
    end
  end


  def new(label, [[ [x, y] | _] |_] = geo_json) when is_atom(label) and is_float(x) and is_float(y) do
    %Within{
      label: label,
      geo_json: geo_json,
    }
  end

  def render(%Within{label: label, geo_json: [[ [x, y] | _] |_] = geo_json }) when is_atom(label) and is_float(x) and is_float(y) do
    "within(#{label}, #{Poison.encode!(geo_json)})"
  end

end