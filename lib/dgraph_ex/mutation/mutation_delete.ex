defmodule DgraphEx.Mutation.MutationDelete do
  alias DgraphEx.{Mutation, Field}
  alias Mutation.{MutationDelete}

  defstruct [
    fields: []
  ]

  def put_field(%MutationDelete{fields: fields} = md, %Field{} = field) do
    %{ md | fields: [field|fields] }
  end

  def render(%MutationDelete{fields: []}) do
    ""
  end
  def render(%MutationDelete{fields: fields}) do
    "delete { " <> (fields |> Enum.map(&Field.as_schema/1) |> Enum.join("\n")) <> " }"
  end

end