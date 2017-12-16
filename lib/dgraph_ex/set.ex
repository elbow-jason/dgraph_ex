defmodule DgraphEx.Set do
  alias DgraphEx.{Set, Field}

  defstruct [
    fields: []
  ]

  defmacro __using__(_) do
    quote do
      alias DgraphEx.{Vertex, Set}

      defp raise_vertex_only_error do
        raise %ArgumentError{
          message: "Dgraph.set structs must be Vertex models only"
        }
      end

      defp check_model(model) do
        if !DgraphEx.Vertex.is_model?(model) do
          raise_vertex_only_error()
        end
      end

      def set() do
        %Set{}
      end

      def set(%module{} = model) do
        check_model(model)
        set(Vertex.setter_subject(model), model)
      end

      def set(subject, %module{} = model) do
        check_model(model)
        fields = Vertex.populate_fields(subject, module, model)
        %Set{fields: fields}
      end

    end
  end

  def put_field(%Set{fields: prev_fields} = set, %Field{} = field) do
    %{ set | fields: [ field | prev_fields ]}
  end

  def merge(%Set{fields: fields1} = mset1, %Set{fields: fields2}) do
    %{ mset1 | fields: [ fields1 ++ fields2 ] }
  end

  def render(%Set{fields: []}) do
    ""
  end
  def render(%Set{fields: fields}) when length(fields) > 0 do
    "{ set { " <> render_fields(fields) <> " } }"
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