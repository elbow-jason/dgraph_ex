defmodule DgraphEx.Expr.Uid do
  alias DgraphEx.Expr.Uid
  alias DgraphEx.Util

  defstruct [
    :value,
    :type,
  ]

  defmacro __using__(_) do
    quote do
      def uid(value) when is_atom(value) or is_binary(value) do
        DgraphEx.Expr.Uid.new(value)
      end
    end
  end

  def new(value) when is_atom(value) do
    %Uid{
      value: value,
      type: :label,
    }
  end
  def new(value) when is_binary(value) do
    %Uid{
      value: value,
      type: :literal,
    }
  end

  def render(%Uid{value: value, type: :literal}) when is_binary(value) do
    Util.as_literal(value, :uid)
  end
  def render(%Uid{value: value, type: :label}) when is_atom(value) and not is_nil(value) do
    to_string(value)
  end
  
end