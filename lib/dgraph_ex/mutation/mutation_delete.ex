defmodule DgraphEx.Mutation.MutationDelete do
  alias DgraphEx.{Mutation, Field}
  alias Mutation.{MutationDelete}
  alias DgraphEx.Expr.{Uid}
  defstruct [
    fields: []
  ]

  defmacro __using__(_) do
    quote do
      alias DgraphEx.Mutation.MutationDelete
      def delete(%Mutation{} = m, subject, predicate, object) do
        MutationDelete.delete(m, subject, predicate, object)
      end
    end
  end

  def delete(%Mutation{} = mut, subject, predicate, object) do
    Mutation.put_sequence(mut, %MutationDelete{
      fields: [
        %Field{
          subject:    subject,
          predicate:  predicate,
          object:     object,
        }
      ]
    })
  end

  def put_field(%MutationDelete{fields: fields} = md, %Field{} = field) do
    %{ md | fields: [ field | fields ] }
  end

  def render(%MutationDelete{fields: []}) do
    ""
  end
  def render(%MutationDelete{fields: fields}) do
    "delete { " <> (fields |> Enum.map(&Field.as_delete/1) |> Enum.join("\n")) <> " }"
  end

end