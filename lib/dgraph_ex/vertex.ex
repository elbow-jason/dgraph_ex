defmodule DgraphEx.Vertex do
  alias DgraphEx.{Vertex, Field}

  defmacro __using__(_opts) do
    quote do
      import Vertex
      import Field
    end
  end

  defmacro vertex(do: block) do
    quote do
      Module.register_attribute(__MODULE__, :vertex_fields, accumulate: true)
      unquote(block)
      
      @fields @vertex_fields |> Enum.reverse()

      defstruct Enum.map(@fields, fn %Field{predicate: p, default: default} -> {p, default} end)
      def fields() do
        @fields
      end

    end
  end

  def schema(module) when is_atom(module) do
    fields =
      module.fields() 
      |> Enum.map(fn %Field{} = f -> Field.as_schema(f) end)
    "schema {\n\t" <> (fields |> Enum.join("\n\t")) <> "\n}"
  end

  def mutation(items) when is_list(items) do
    items
    |> Enum.join("\n\t")
    |> mutation
  end
  def mutation(item) when is_binary(item) do
    "mutation { \n" <> item <> "\n}"
  end

  def as_setter(subject, model = %{__struct__: _}) do
    subject
    |> populate_fields(model)
    |> Enum.map(&Field.as_setter/1)
  end

  
  def as_variables(subject, model) do
    subject
    |> populate_fields(model)
    |> Enum.map(fn field -> Field.as_variables(field) end)
  end


  def populate_fields(subject, model = %{__struct__: module}) do
    populate_fields(subject, module, model)
  end
  def populate_fields(subject, module, model) do
    module.fields()
    |> Enum.map(fn field ->
      object =
        model
        |> Map.get(field.predicate)
      if not is_nil(object) do
        field
        |> Field.put_subject(subject)
        |> Field.put_object(object)
      else
        nil
      end
    end)
    |> Enum.filter(fn item -> item end)
  end
end