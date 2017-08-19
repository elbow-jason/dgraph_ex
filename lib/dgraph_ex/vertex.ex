defmodule DgraphEx.Vertex do
  alias DgraphEx.{Vertex, Field, Query, Util}
  alias DgraphEx.Expr.Uid

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
    |> Enum.filter(fn
      %{predicate: :_uid_} -> false
      _ -> true
    end)
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
      {_, false} -> false
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
      cond do
        Vertex.is_model?(object) ->
          sub_subject = Vertex.setter_subject(object, field.predicate)
          relationship =
            field
            |> Field.put_subject(subject)
            |> Field.put_object(sub_subject)
          [ relationship | populate_fields(sub_subject, object) ]
        !is_nil(object) -> 
          field
          |> Field.put_subject(subject)
          |> Field.put_object(object)
        true ->
          nil
      end
    end)
    |> List.flatten
    |> Enum.filter(fn item -> item end)
  end

  def join_model_and_uids(%{__struct__: module } = model, uids) do
    label =
      module.__vertex__(:default_label)
      |> to_string

    join_model_and_uids(model, uids, label)
  end
  def join_model_and_uids(model, uids, label) when is_atom(label) do
    join_model_and_uids(model, uids, to_string(label))
  end
  def join_model_and_uids(%{__struct__: _} = model, uids, label) when is_binary(label) do
    uid = Map.get(uids, label)
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

  def extract_uids(model) do
    extract_uids(model, model.__struct__.__vertex__(:default_label))
  end
  def extract_uids(model, subject) do
    if not is_model?(model) do
      raise """
        Cannot extract the uids from non-Vertex models. Got #{inspect model}
      """
    end
    model
    |> do_extract_uids(subject)
    |> Enum.map(fn {pred, uid} -> {to_string(pred), uid} end)
    |> Enum.into(%{})
  end

  def do_extract_uids(model, subject) do
    model
    |> Map.from_struct
    |> Enum.reduce([], fn
      ({:_uid_, %Uid{value: uid}}, acc) when is_binary(uid) ->
        [ {subject, uid} | acc ]
      ({:_uid_, uid}, acc) when is_binary(uid) ->
        [ {subject, uid} | acc ]
      ({key, %{__struct__: _} = other_model}, acc) ->
        do_extract_uids(other_model, key) ++ acc
      (_, acc) ->
        acc
    end)
  end

  # def do_extract_uids(model, subject) do
  #   populate_fields(subject, model)
  #   |> Enum.filter(fn
  #     %{object: %Uid{}} ->
  #       true
  #     %{type: :uid, object: uid} when is_binary(uid) ->
  #       true
  #     _ ->
  #       false
  #   end)
  #   |> Enum.reduce([], fn
  #     (%{predicate: pred, object: %Uid{value: uid}}, acc) ->
  #       [ {pred, uid} | acc ]
  #     (%{predicate: pred, object: %{__struct__: _} = other_model, type: :uid}, acc) ->
  #       do_extract_uids(pred, other_model) ++ acc
  #     (%{predicate: pred, object: uid}, acc) when is_binary(uid) ->
  #       [ {pred, uid} | acc ]
  #   end)
  # end

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

  def setter_subject(model, default \\ nil)
  def setter_subject(%Uid{} = uid, _) do
    uid.value
  end
  def setter_subject(%{__struct__: module} = model, default) do
    if !DgraphEx.Util.has_function?(module, :__vertex__, 1) do
      raise("""
        Vertex.setter_subject only responds to Vertex models.
        Got #{inspect model}
      """)
    end
    do_setter_subject(model, default)
  end

  def do_setter_subject(%{_uid_: uid}, _) when is_binary(uid) do
    uid
    |> Uid.new
    |> Uid.as_literal
  end
  def do_setter_subject(%{_uid_: %Uid{} = uid}, _) do
    uid
    |> Uid.as_literal
  end
  def do_setter_subject(%{__struct__: module}, nil) do
    module.__vertex__(:default_label)
  end
  def do_setter_subject(_, default) when not is_nil(default) do
    default
  end

  def populate_model(_, nil) do
    # nil params gets you nil.
    nil
  end
  def populate_model(%{__struct__: _} = model, params_list) when is_list(params_list) do
    # params had a list
    # so we should populate each item of the list with a model.
    Enum.map(params_list, fn params -> populate_model(model, params) end)
  end
  def populate_model(module, params) when is_atom(module) do
    populate_model(module.__struct__, params)
  end
  def populate_model(%{__struct__: module} = model, %{} = params) do
    do_populate_model(module, model |> Map.from_struct, params)
  end
  defp do_populate_model(module, model_data, params) do
    model_data
    |> Enum.map(fn
      {key, module} when is_atom(module) and not is_nil(module) ->
        sub_params = Util.get_value(params, key, nil)
        {key, populate_model(module.__struct__, sub_params)}

      {key, %{__struct__: _} = sub_model} ->
        sub_params = Util.get_value(params, key, nil)
        {key, populate_model(sub_model, sub_params)}

      {key, model_value} ->
        {key, Util.get_value(params, key, model_value)}

    end)
    |> Enum.reduce(model_data, fn ({key, value}, model_acc) ->
      Map.put(model_acc, key, value)
    end)
    |> Map.put(:__struct__, module)
  end

  # defp populate_submodel(sub_model, sub_params) do
  #   case Util.get_value(params, key, nil) do
  #     params_list when is_list(params_list) ->
  #       # params had a list
  #       # so we should populate each item of the list with a submodel.
  #       models = Enum.map(params_list, fn
  #         sub_params -> populate_model(sub_model, sub_params)
  #       end)
        
  #     %{} = sub_params ->
  #       # params had a submap so we populate it
  #       populate_model(sub_model, sub_params))
  #     nil ->
  #       # the params had no submap for this key
  #       nil
  #   end
  # end
end
