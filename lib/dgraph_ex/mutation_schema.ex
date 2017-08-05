defmodule DgraphEx.MutationSchema do
  alias DgraphEx.{MutationSchema, Field}

  defstruct [
    fields: []
  ]

  def put_field(%MutationSchema{fields: prev_fields} = schema, %Field{} = field) do
    %{ schema | fields: [ field | prev_fields ]}
  end

  def render(%MutationSchema{fields: []}) do
    ""
  end
  def render(%MutationSchema{fields: fields}) do
    " schema { " <> (fields |> Enum.map(&Field.as_schema/1) |> Enum.join("\n")) <> " } "
  end
end