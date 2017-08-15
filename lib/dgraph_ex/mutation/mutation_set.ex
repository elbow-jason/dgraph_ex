defmodule DgraphEx.Mutation.MutationSet do
  alias DgraphEx.Mutation.MutationSet
  alias DgraphEx.Field
  alias DgraphEx.Expr.{Uid}

  defstruct [
    fields: []
  ]

  defmacro __using__(_) do
    quote do
      alias DgraphEx.{Mutation, Vertex}
      alias Mutation.MutationSet

      def set(%Mutation{} = mut) do
        Mutation.put_sequence(mut, %MutationSet{})
      end

      defp raise_vertex_only_error do
        raise %ArgumentError{
          message: "MutationSet.set structs must be Vertex models only"
        }
      end

      def set(%Mutation{} = mut, %{__struct__: module} = model) do
        if DgraphEx.Util.has_function?(module, :__vertex__, 1) do
          case model do
            %{_uid_: uid} when is_binary(uid) -> 
              set(mut, uid |> Uid.new |> Uid.as_literal, model)
            %{_uid_: %Uid{} = uid} -> 
              set(mut, uid |> Uid.as_literal, model)
            _ ->
              subject = module.__vertex__(:default_label)
              set(mut, subject, model)
          end
        else
          raise_vertex_only_error()
        end
      end

      def set(%Mutation{} = mut, subject, %{__struct__: module} = model) do
        if DgraphEx.Util.has_function?(module, :__vertex__, 1) do
          Mutation.put_sequence(mut, %MutationSet{
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

  def merge(%MutationSet{fields: fields1} = mset1, %MutationSet{fields: fields2}) do
    %{ mset1 | fields: [ fields1 ++ fields2 ] }
  end

  def render(%MutationSet{fields: []}) do
    ""
  end
  def render(%MutationSet{fields: fields}) when length(fields) > 0 do
    "set { " <> render_fields(fields) <> " }"
  end

  defp render_fields(fields) do
    fields
    |> remove_uid
    |> Enum.map(&Field.as_setter/1)
    |> List.flatten
    |> Enum.join("\n")
  end

  defp remove_uid(fields) when is_list(fields) do
    Enum.filter(fields, &remove_uid/1)
  end
  defp remove_uid(%{predicate: :_uid_}) do
    false
  end
  defp remove_uid(x) do
    x
  end
  
end