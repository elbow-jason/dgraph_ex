defmodule DgraphEx.Query.As do
  alias DgraphEx.{Query}
  alias Query.{As}

  defstruct [
    identifier: nil,
  ]

  defmacro __using__(_) do
    quote do
      alias DgraphEx.Query
      def as(%Query{} = q, identifier) do
        Query.put_sequence(q, %Query.As{identifier: identifier})
      end
      def as(identifier) do
        %As{identifier: identifier}
      end
      def as() do
        %As{}
      end
    end
  end

  def render(%As{identifier: id}) do
    "#{id} as "
  end

end