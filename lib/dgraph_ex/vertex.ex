defmodule DgraphEx.Vertex do
  alias DgraphEx.{Vertex, Field}

  defmacro __using__(_opts) do
    quote do
      import Vertex
      import Field
    end
  end

  defmacro vertex(default_label, do: block) when is_atom(default_label) do
    quote do
      Module.register_attribute(__MODULE__, :vertex_fields, accumulate: true)
      unquote(block)
      @fields (@vertex_fields |> Enum.reverse()) ++ [
        %Field{type: :uid_literal, predicate: :_uid_}
      ]

      defstruct Enum.map(@fields, fn %Field{predicate: p, default: default} -> {p, default} end)
      def __vertex__(:fields) do
        @fields
      end
      def __vertex__(:default_label) do
        unquote(default_label)
      end

    end
  end

  defmacro query_model() do
    quote do
      alias DgraphEx.Query
      def model(%Query{} = q, subject, %{__struct__: _} = the_model) do
        subject 
        |> DgraphEx.Vertex.populate_fields(the_model)
        |> Enum.reduce(q, fn (field, acc_q) ->
          case {field.object, field.model} do
            {_, nil} -> 
              acc_q
              |> Query.put_sequence(field)
            {%{__struct__: module} = object, module} -> 
              model(q, field.subject, field.object)
          end
        end)
      end
    end
  end
  

  def schema(module) when is_atom(module) do
    fields =
      :fields
      |> module.__vertex__() 
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
    module.__vertex__(:fields)
    |> Enum.map(fn field ->
      object = Map.get(model, field.predicate, nil)
      if not is_nil(object) do
        field
        |> Field.put_subject(subject)
        |> Field.put_object(object)
      else
        nil
      end
    end)
    |> List.flatten
    |> Enum.filter(fn item -> item end)
  end

end