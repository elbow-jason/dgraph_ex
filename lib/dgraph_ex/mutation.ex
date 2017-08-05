defmodule DgraphEx.Mutation do
  alias DgraphEx.{
    Field,
    Mutation,
    MutationSet,
    MutationSchema,
  }

  defstruct [
    set: %MutationSet{},
    schema: %MutationSchema{},
  ]

  def put_set(%Mutation{set: set} = m, %Field{} = f) do
    %{ m | set: set |> MutationSet.put_field(f) }
  end

  def put_schema(%Mutation{schema: schema} = m, %Field{} = f) do
    %{ m | schema: schema |> MutationSchema.put_field(f) }
  end

  def render(mutation, mode \\ :raw)
  def render(%Mutation{set: set, schema: schema}, _mode) do
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