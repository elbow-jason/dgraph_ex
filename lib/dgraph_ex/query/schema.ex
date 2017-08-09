defmodule DgraphEx.Query.Schema do
  alias DgraphEx.{Query, Field}
  alias Query.{Schema}

  defstruct [
    fields: []
  ]

  defmacro __using__(_) do
    quote do
      alias DgraphEx.Query
      def schema(%Query{} = q) do
        Query.put_sequence(q, %Schema{})
      end
    end
  end

  def put_field(%Schema{fields: prev_fields} = schema, %Field{} = field) do
    %{ schema | fields: [ field | prev_fields ] }
  end

  def render(%Schema{fields: fields}) do
    "schema { "<>(fields |> Enum.map(&Field.as_schema/1) |> Enum.join("\n"))<>" }"
  end

end