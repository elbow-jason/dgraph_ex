defmodule DgraphEx.Delete do
  alias DgraphEx.{Field}
  alias DgraphEx.Delete

  defstruct [
    fields: []
  ]

  def path, do: "/query"

  defmacro __using__(_) do
    quote do
      alias DgraphEx.Delete
      def delete(subject, predicate, object) do
        Delete.delete(subject, predicate, object)
      end
      def delete(%Delete{} = m, block) do
        Delete.delete(m, block)
      end
      def delete(block) do
        Delete.delete(block)
      end
    end
  end
  def delete(%Field{} = field) do
     put_field(%Delete{}, field)
  end
  def delete(block) when is_tuple(block)  do
    fields =
      block
      |> Tuple.to_list
     put_field(%Delete{}, fields)
  end
  def delete(subject, predicate, object) do
    field = Field.delete_field(subject, predicate, object)
    put_field(%Delete{}, field)
  end
  def delete(%Delete{} = del, %Field{} = field) do
    put_field(del, field)
  end


  def put_field(%Delete{} = md, fields) when is_list(fields) do
    Enum.reduce(fields, md, fn (field, acc_md) -> put_field(acc_md, field) end)
  end
  def put_field(%Delete{fields: prev_fields} = md, %Field{} = field) do
    %{ md | fields: [ field | prev_fields ] }
  end

  def render(%Delete{fields: []}) do
    ""
  end
  def render(%Delete{fields: fields}) do
    "{ delete { " <> render_fields(fields) <> " } }"
  end
  defp render_fields(fields) do
    fields
    |> Enum.reverse
    |> Enum.map(&Field.as_delete/1)
    |> Enum.join("\n")
  end

end