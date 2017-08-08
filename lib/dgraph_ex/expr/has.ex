defmodule DgraphEx.Expr.Has do
  alias DgraphEx.Expr.Has

  defstruct [
    value: nil
  ]

  defmacro __using__(_) do
    quote do
      alias DgraphEx.Expr.Has
      
      def has(value) do
        Has.new(value)
      end
    end
  end

  def new(value) when is_atom(value) do
    %Has{
      value: value
    }
  end

  def render(%Has{value: value}) do
    "has("<>to_string(value)<>")"
  end

end