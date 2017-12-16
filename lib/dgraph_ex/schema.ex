defmodule DgraphEx.Schema do
  alias DgraphEx.{Schema, Query, Field, Mutation}

  @naked_fields [
    :type,
    :index,
    :reverse,
    :tokenizer,
  ]

  defstruct [
    context: nil,
    fields:  [],
  ]

  defmacro __using__(_) do
    quote do
      alias DgraphEx.{Query, Vertex, Set}

      defp raise_non_vertex_module(module) do
        raise %ArgumentError{
          message: "schema only responds to Vertex models. #{module} does not use DgraphEx.Vertex"
        }
      end
      def schema(%Set{} = set, module) when is_atom(module) do
        if !Vertex.is_model?(module) do
          raise_non_vertex_module(module)
        end
        Set.put_field(set, %Schema{
          fields: module.__vertex__(:fields),
        })
      end
      def schema(%Set{} = set, block) when is_tuple(block) do
        %Set{fields: block |> Tuple.to_list}
      end
      def schema(block) when is_tuple(block) do
        fields =
          block
          |> Tuple.to_list
          |> Enum.map(fn
            %Field{predicate: pred} -> pred
            pred when is_atom(pred) -> pred
          end)
        %Schema{
          fields: fields,
        }
      end
      def schema(module) when is_atom(module) do
        if Vertex.is_model?(module) do
          fields = 
            module.__vertex__(:fields)
            |> Enum.map(fn %Field{predicate: pred} -> pred end)
          %Schema{
            fields: fields, 
          }
        else
          raise_non_vertex_module(module)
        end
      end
      def schema(%{__struct__: module}) do
        schema(module)
      end
    end
  end


  def render(%Schema{fields: [], context: nil}) do
    "schema {\n#{@naked_fields |> Enum.join("\n")}\n}"
  end
  def render(%Schema{fields: fields, context: nil}) when length(fields) > 0 do
    "schema(pred: [#{fields |> Enum.join(", ")}]) {\n#{@naked_fields |> Enum.join("\n")}\n}"
  end
  def render(%Schema{fields: fields, context: :mutation}) do
    rendered =
      fields
      |> Enum.map(&Field.as_schema/1)
      |> Enum.join("\n")
    "schema {\n" <> rendered <> "\n}"
  end


end