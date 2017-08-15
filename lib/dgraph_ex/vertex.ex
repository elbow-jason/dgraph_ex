defmodule DgraphEx.Vertex do
  alias DgraphEx.{Vertex, Field, Query}

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

  def as_selector(module) when is_atom(module) do
    as_selector(module.__struct__)
  end
  def as_selector(model = %{__struct__: _}) do
    model
    |> Map.from_struct
  
    |> Map.drop([:__struct__])
    |> Enum.filter(fn
      {key, false} -> false
      _ -> true
    end)
    |> Enum.map(fn
      {key, %{__struct__: _} = submodel} -> { key, Query.Select.new(submodel) }
      {key, _} -> {key, nil}
    end)
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

  def join_model_and_uids(%{__struct__: _ } = model, uids, label \\ nil) do
    uid = Map.get(uids, label_string(model, label))
    model
    |> Map.from_struct
    |> Enum.reduce(model, fn
      ({key, %{__struct__: _} = submodel}, acc_model) ->
        Map.put(acc_model, key, join_model_and_uids(submodel, uids, key))
      (_, acc_model) ->
        acc_model
    end)
    |> Map.put(:_uid_, uid)
  end

  defp label_string(_, label) when not is_nil(label) do
    to_string(label)
  end
  defp label_string(%{__struct__: module}, nil) do
    module.__vertex__(:default_label) |> to_string
  end

  def get_field(module, predicate) do
    module.__vertex__(:fields)
    |> Enum.find(fn f -> f.predicate == predicate end)
  end

  def is_model?(%{__struct__: module}) do
    is_model?(module)
  end
  def is_model?(module) when is_atom(module) do
    DgraphEx.Util.has_function?(module, :__vertex__, 1)
  end
  def is_model?(_) do
    false
  end

end
