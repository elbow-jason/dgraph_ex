defmodule DgraphEx.Expr.Contains do
  alias DgraphEx.Expr.Contains

  defstruct [
    label: nil,
    geo_json: nil,
  ]

  defmacro __using__(_) do
    quote do
      alias DgraphEx.Expr.Contains

      def contains(label, geo_json) when is_atom(label) and is_list(geo_json) do
        Contains.new(label, geo_json)
      end
    end
  end


  def new(label, geo_json) when is_atom(label) and is_list(geo_json) do
    %Contains{
      label: label,
      geo_json: geo_json,
    }
  end

  def render(%Contains{label: label, geo_json: geo_json}) when is_atom(label) and is_list(geo_json) do
    "contains(#{label}, #{Poison.encode!(geo_json)})"
  end

end