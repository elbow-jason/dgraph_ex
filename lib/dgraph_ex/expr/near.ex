defmodule DgraphEx.Expr.Near do
  alias DgraphEx.Expr.Near

  defstruct [
    label: nil,
    geo_json: nil,
    distance: nil,
  ]

  defmacro __using__(_) do
    quote do
      alias DgraphEx.Expr.Near

      def near(label, [x, y] = geo_json, distance) when is_atom(label) and is_float(x) and is_float(y) and is_integer(distance) do
        Near.new(label, geo_json, distance)
      end
    end
  end


  def new(label, [x, y] = geo_json, distance) when is_atom(label) and is_float(x) and is_float(y) and is_integer(distance) do
    %Near{
      label: label,
      geo_json: geo_json,
      distance: distance,
    }
  end

  def render(%Near{label: label, geo_json: [x, y] = geo_json, distance: distance}) when is_atom(label) and is_float(x) and is_float(y) and is_integer(distance) do
    "near(" <> render_args([label, geo_json, distance]) <> ")"
  end

  defp render_args(args) when is_list(args) do
    args
    |> Enum.map(fn
      item when is_list(item) -> Poison.encode!(item)
      item -> to_string(item)
    end)
    |> Enum.join(", ")
  end
end