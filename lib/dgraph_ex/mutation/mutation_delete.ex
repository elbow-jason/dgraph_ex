defmodule DgraphEx.Mutation.MutationDelete do
  alias DgraphEx.{Mutation, Field}
  alias Mutation.{MutationDelete}

  defstruct [
    fields: []
  ]

  defmacro __using__(_) do
    quote do
      alias DgraphEx.Mutation.MutationDelete
      def delete(%Mutation{} = m, subject, predicate, object) do
        MutationDelete.delete(m, subject, predicate, object)
      end
      def delete(%Mutation{} = m, block) do
        MutationDelete.delete(m, block)
      end
    end
  end
  def delete(%Mutation{} = mut, block) when is_tuple(block)  do
    fields =
      block
      |> Tuple.to_list
    Mutation.put_sequence(mut, %MutationDelete{} |> put_field(fields))
  end
  def delete(%Mutation{} = mut, subject, predicate, object) do
    field =
      Field.delete_field(subject, predicate, object)
    Mutation.put_sequence(mut, %MutationDelete{} |> put_field(field))
  end
  def delete(%Mutation{} = mut, %Field{} = field) do
    Mutation.put_sequence(mut, %MutationDelete{} |> put_field(field))
  end

  def put_field(%MutationDelete{} = md, fields) when is_list(fields) do
    Enum.reduce(fields, md, fn (field, acc_md) -> put_field(acc_md, field) end)
  end
  def put_field(%MutationDelete{fields: prev_fields} = md, %Field{} = field) do
    %{ md | fields: [ field | prev_fields ] }
  end

  def render(%MutationDelete{fields: []}) do
    ""
  end
  def render(%MutationDelete{fields: fields}) do
    "delete { " <> render_fields(fields) <> " }"
  end
  defp render_fields(fields) do
    fields
    |> Enum.reverse
    |> Enum.map(&Field.as_delete/1)
    |> Enum.join("\n")
  end

end