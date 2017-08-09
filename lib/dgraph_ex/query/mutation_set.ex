defmodule DgraphEx.Query.MutationSet do
  alias DgraphEx.Query.MutationSet
  alias DgraphEx.Field

  defstruct [
    fields: []
  ]

  defmacro __using__(_) do
    quote do
      alias DgraphEx.{Query, Vertex}
      alias Query.MutationSet

      def set(%Query{} = q) do
        Query.put_sequence(q, MutationSet)
      end

      defp raise_vertex_only_error do
        raise %ArgumentError{
          message: "MutationSet.set structs must be Vertex models only"
        }
      end

      def set(%Query{} = q, %{__struct__: module} = model) do
        if DgraphEx.Util.has_function(module, :__vertex__, 1) do
          subject = module.__vertex__(:default_label)
          set(q, subject, model)
        else
          raise_vertex_only_error()
        end
      end

      def set(%Query{} = q, subject, %{__struct__: module} = model) when is_atom(subject) do
        if DgraphEx.Util.has_function(module, :__vertex__, 1) do
          Query.put_sequence(q, %MutationSet{
            fields: Vertex.populate_fields(subject, module, model)
          })
        else
          raise_vertex_only_error()
        end
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
    "set { " <> (fields |> Enum.map(&Field.as_setter/1) |> Enum.join("\n")) <> " }"
  end
end