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

  @types [
    :literal,
    :expression,
  ]

  def new(value) do
    case value do
      x when is_atom(x)   -> new(x, :expression)
      x when is_binary(x) -> new(x, :literal)
    end
  end
  def new(value, type) when (is_atom(value) or is_binary(value)) and type in @types do
    %Uid{
      value: value,
      type: type,
    }
  end

  @doc """
  This function is used by Func to ensure that a uid string ("0x9") is rendered
  as an expression literal `uid(0x9)` instead of an actual literal `<0x9>`
  """
  def as_expression(%Uid{} = u) do
    %{ u | type: :expression }
  end

  def as_literal(%Uid{} = u) do
    %{ u | type: :literal }
  end

  def render(%Uid{value: value, type: :literal}) when is_binary(value) do
    Util.as_literal(value, :uid)
  end
  def render(%Uid{value: value, type: :expression}) do
    "uid("<>to_string(value)<>")"
  end

end