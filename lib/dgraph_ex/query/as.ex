defmodule DgraphEx.Query.As do
  alias DgraphEx.{Query}
  alias Query.{As}

  defstruct [
    identifier: nil,
    block: nil,
  ]

  defmacro __using__(_) do
    quote do
      alias DgraphEx.Query
      def as(%Query{} = q, identifier) do
        Query.put_sequence(q, %Query.As{identifier: identifier})
      end
    end
  end

  def render(%As{identifier: id, block: block}) do
    "#{id} as #{render_block(block)}"
  end

  defp render_block(block) do
    "#{block}"
  end
  
end