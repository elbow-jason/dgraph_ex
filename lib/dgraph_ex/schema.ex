defmodule DgraphEx.Schema do
  alias DgraphEx.{Schema, Query, Field, Mutation}

  defstruct [
    context: nil,
    fields: [],
  ]

  defmacro __using__(_) do
    quote do
      alias DgraphEx.Query
      def schema(%Mutation{} = mut, module) when is_atom(module) do
        Mutation.put_sequence(mut, %Schema{
          context: :mutation,
          fields: module.__vertex__(:fields),
        })
      end
      def schema(%Mutation{} = mut, block) when is_tuple(block) do
        Mutation.put_sequence(mut, %Schema{
          context: :mutation,
          fields: block |> Tuple.to_list,
        })
      end
      def schema(%Query{} = q, block) when is_tuple(block) do
        Query.put_sequence(q, %Schema{
          context: :naked,
          fields: block |> Tuple.to_list,
        })
      end
    end
  end

  def as_getter(%Schema{} = s) do
    %{ s | context: :naked }
  end
  def as_mutation(%Schema{} = s) do
    %{ s | context: :mutation }
  end

  def put_field(%Schema{fields: prev_fields} = schema, %Field{} = field) do
    %{ schema | fields: [ field | prev_fields ] }
  end

  def render(%Schema{fields: fields, context: :naked}) do
    "schema { "<>(fields |> Enum.map(fn f -> f.predicate end) |> Enum.join("\n"))<>" }"
  end
  def render(%Schema{fields: fields, context: :mutation}) do
    "schema { "<>(fields |> Enum.map(&Field.as_schema/1) |> Enum.join("\n"))<>" }"
  end

end