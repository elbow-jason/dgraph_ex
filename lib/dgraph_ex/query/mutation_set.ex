defmodule DgraphEx.Query.MutationSet do
  alias DgraphEx.Query.MutationSet
  alias DgraphEx.Field

  defstruct [
    fields: []
  ]

  defmacro __using__(_) do
    quote do
      alias DgraphEx.Query
      def set(%Query{} = q) do
        Query.put_sequence(q, Query.MutationSet)
      end
    end
  end

  def put_field(%MutationSet{fields: prev_fields} = set, %Field{} = field) do
    %{ set | fields: [ field | prev_fields ]}
  end

  def render(%MutationSet{fields: []}) do
    ""
  end
  def render(%MutationSet{fields: fields}) when length(fields) > 0 do
    " set { " <> (fields |> Enum.map(&Field.as_setter/1) |> Enum.join("\n")) <> " } "
  end
end