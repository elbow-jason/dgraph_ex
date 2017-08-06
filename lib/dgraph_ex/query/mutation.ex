defmodule DgraphEx.Query.Mutation do
  alias DgraphEx.{
    Field,
    Query,
  } 
  alias Query.{
    Mutation,
    MutationSet,
    MutationSchema,
    MutationDelete,
  }

  defstruct [
    set:    %MutationSet{},
    schema: %MutationSchema{},
    delete: %MutationDelete{},
  ]

  defmacro __using__(_) do
    quote do
      alias DgraphEx.Query
      def mutation(%Query{} = d) do
        Query.put_sequence(d, Mutation)
      end
    end
  end

  def put_set(%Mutation{set: set} = m, %Field{} = f) do
    %{ m | set: set |> MutationSet.put_field(f) }
  end

  def put_schema(%Mutation{schema: schema} = m, %Field{} = f) do
    %{ m | schema: schema |> MutationSchema.put_field(f) }
  end

  def put_delete(%Mutation{delete: delete} = m, %Field{} = f) do
    %{ m | delete: delete |> MutationSchema.put_field(f) }
  end

  def render(%Mutation{set: set, schema: schema}) do
    body = 
      [
        MutationSet.render(set),
        MutationSchema.render(schema),
      ]
      |> Enum.filter(fn
        "" -> false
        item -> item
      end)
      |> Enum.join("\n")
    "mutation {\n" <> body <> "\n}"
  end

end