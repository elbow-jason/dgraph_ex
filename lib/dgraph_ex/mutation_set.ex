defmodule DgraphEx.MutationSet do
  alias DgraphEx.{MutationSet, Field}

  defstruct [
    fields: []
  ]

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