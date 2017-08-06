defmodule DgraphEx.Query.Uid do
  alias DgraphEx.Query.Uid
  alias DgraphEx.Util

  defstruct [
    :value,
    :type,
  ]

  defmacro __using__(_) do
    quote do
      def uid(value) when is_atom(value) do
        DgraphEx.Query.Uid.new(value)
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