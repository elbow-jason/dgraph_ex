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
      alias DgraphEx.{Query, Vertex}

      defp raise_non_vertex_module(module) do
        raise %ArgumentError{
          message: "schema only responds to Vertex models. #{module} does not use DgraphEx.Vertex"
        }
      end

      @doc """
      Get all the fields that are not marked as virtual
      """
      defp get_non_virtual_fields(module) when is_atom(module) do
        module.__vertex__(:fields)
        |> Enum.filter(&(&1.virtual == nil || &1.virtual == false))
      end

      def schema(%Mutation{} = mut, module) when is_atom(module) do
        if Vertex.is_model?(module) do
          Mutation.put_sequence(mut, %Schema{
            context: :mutation,
            fields: get_non_virtual_fields(module),
          })
        else
          raise_non_vertex_module(module)
        end
      end
      def schema(%Mutation{} = mut, block) when is_tuple(block) do
        Mutation.put_sequence(mut, %Schema{
          context: :mutation,
          fields: block |> Tuple.to_list,
        })
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
            get_non_virtual_fields(module)
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