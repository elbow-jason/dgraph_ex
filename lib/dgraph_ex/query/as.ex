defmodule DgraphEx.Query.As do
  alias DgraphEx.{Query}
  alias Query.{As}

  defstruct [
    identifier: nil,
    block: nil
  ]

  defmacro __using__(_) do
    quote do
      alias DgraphEx.Query
      def as(%Query{} = q, identifier) do
        Query.put_sequence(q, %Query.As{identifier: identifier})
      end
      def as(ident, %{__struct__: _} = block) when is_atom(ident) do
        %As{identifier: ident, block: block}
      end
      def as(ident) when is_atom(ident) do
        %As{identifier: ident}
      end
      def as() do
        %As{}
      end
    end
  end

  def render(%As{identifier: id, block: %{__struct__: module} = model}) do
    "#{id} as #{module.render(model)}"
  end
  def render(%As{identifier: id}) do
    "#{id} as"
  end

end