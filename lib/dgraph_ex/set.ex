defmodule DgraphEx.Set do
  alias DgraphEx.{Set, Field}

  def path, do: "/mutate"

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
      def set(items) when is_list(items) do
        DgraphEx.Kwargs.query(items)
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
    lines =
      fields
      |> render_fields(4)
    "{\n  set {\n" <> lines <> "\n  }\n}"
  end

  defp render_fields(fields, indent) do
    fields
    |> remove_uid
    |> Enum.map(&Field.as_setter/1)
    |> List.flatten
    |> Enum.map(fn item -> left_pad(item, indent, " ") end)
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
  
  defp left_pad(item, count, padding) do
    1..count
    |> Enum.map(fn _ -> padding end)
    |> Enum.join("")
    |> Kernel.<>(item)
  end

end