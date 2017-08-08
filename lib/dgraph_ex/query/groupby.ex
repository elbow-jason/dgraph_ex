defmodule DgraphEx.Query.Groupby do
  alias DgraphEx.Query.Groupby

  defstruct [
    predicate: nil
  ]

  defmacro __using__(_) do
    quote do
      alias DgraphEx.Query.Groupby
      def groupby(pred) when is_atom(pred) do
        Groupby.new(pred)
      end
    end
  end

  def new(pred) when is_atom(pred) do
    %Groupby{
      predicate: pred
    }
  end

  @doc """
  Examples:

    iex> %DgraphEx.Query.Groupby{predicate: :thing} |> DgraphEx.Query.Groupby.render
    "@groupby(thing)"

    """
  def render(%Groupby{predicate: p}) when is_atom(p) do
    "@groupby(#{p})"
  end

end