defmodule DgraphEx.Schema do
  alias DgraphEx.{Schema, Query, Field, Mutation}

  defstruct [
    context: nil,
    fields: [],
  ]

  defmacro __using__(_) do
    quote do
      alias DgraphEx.{Query, Vertex}

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
      def schema(block) when is_tuple(block) do
        %Schema{
          fields: block |> Tuple.to_list,
        }
      end
      def schema(%{__struct__: module} = model) do
        if Vertex.is_model?(model) do
          %Schema{
            fields: module.__vertex__(:fields)
          }
        else
          raise %ArgumentError{
            message: "schema/1 structs can only be Vertex models. #{module} does not use DgraphEx.Vertex"
          }
        end
      end
    end
  end

  def put_field(%Schema{fields: prev_fields} = schema, %Field{} = field) do
    %{ schema | fields: [ field | prev_fields ] }
  end

  def render(%Schema{} = schema) do
    "schema { #{render_fields(schema)} }"
  end

  defp render_fields(%Schema{fields: fields, context: context}) do
    fields
    |> Enum.map(fn f -> render_field(f, context) end)
    |> Enum.join("\n")
  end

  defp render_field(predicate, _context = nil) when is_atom(predicate) do
    to_string(predicate)
  end
  defp render_field(%Field{predicate: predicate}, _context = nil) do
    render_field(predicate, nil)
  end
  defp render_field(%Field{} = f, :mutation) do
    Field.as_schema(f)
  end

end