defmodule DgraphEx.Changeset do
  alias DgraphEx.Changeset, as: Cs
  alias DgraphEx.{Field, Vertex, Types}
  
  defstruct [
    module:   nil,
    model:    nil,
    changes:  nil,
    errors:   nil,
  ]

  @doc """
  In `cast/3` we do 3 things:
  
  1) We ensure only changes to allowed fields "get through" by using Map.take/2.

  2) We separate the model's struct into it's component parts: module and map.
  
  3) We initialize the errors field to an empty list. And since only a
  changeset with an empty list is valid we ensure that a changeset
  has been instantiated outside cast/3 is not valid unless the errors
  field is set to an empty list.
  """
  def cast(%{__struct__: module} = model, %{} = changes, allowed_fields) when is_list(allowed_fields) do
    %Cs{
      module: module,
      model: model |> Map.from_struct,
      changes: Map.take(changes, allowed_fields),
      errors: [],
    }
  end

  @doc """
  In uncast/1 we first check to make sure that the errors field of the changeset is a list.
  If the errors field is not a list then this is not a valid changeset and an error is raised.

  NOTE: A NON-LIST ERRORS FIELD IS NOT ALLOWED. USE CAST/3.
  
  The errors field being a non-list indicates that there was an error in programming, not invalid
  input into a changes map. If you need to construct a Changeset struct outside cast/3 then ensure the errors field
  is set to a list upon instantiation.

  After checking for a non-list errors field, we check is_valid?/1 which returns true only for empty
  errors fields of changesets. If the Changeset is valid we apply each of the changes to the
  model's map and reconstruct the original struct with the changes applied, and return an
  :ok tuple as in `{:ok, model_struct_here}`. Finally, if the changeset was not valid we
  return an :error tuple as in `{:error, changeset_here}`.

  This should be the final function called for a chain of changeset functions (such as validators).
  """
  def uncast(%Cs{} = cs) do
    cond do
      !is_list(cs.errors) ->
        raise %ArgumentError{
          message: "A DgraphEx Changeset requires the :errors field to be a keyword list. Got #{inspect cs.errors}.\nDid you use cast/3 to construct your changeset?"
        }
      is_valid?(cs) -> 
        {:ok, struct!(cs.module, do_apply_changes(cs))}
      true ->
        {:error, cs}
    end
  end

  defp do_apply_changes(%Cs{} = cs) do
    cs.model
    |> Enum.reduce(cs.model, fn ({key, _}, model_acc) ->
      Map.put(model_acc, key, do_get_value(cs, key))
    end)
  end

  def is_valid?(%Cs{errors: []}) do
    true
  end
  def is_valid?(%Cs{}) do
    false
  end

  def put_error(%Cs{errors: errors} = cs, {key, reason} = err) when is_atom(key) and is_atom(reason) do
    %{ cs | errors: [ err | errors ]}
  end

  def validate_required(%Cs{} = cs, required_fields) do
    cs
    |> validate_required_errors(required_fields)
    |> Enum.reduce(cs, fn
      (err, acc_cs) -> put_error(acc_cs, err)
    end)
  end

  defp validate_required_errors(%Cs{} = cs, required_fields) do
    required_fields
    |> Enum.map(fn key -> {key, do_get_value(cs, key)} end)
    |> Enum.reduce([], fn
      ({key, nil}, acc) -> [ {key, :cannot_be_nil} | acc ]
      ({key, ""},  acc) -> [ {key, :cannot_be_empty_string} | acc ]
      (_, acc)          -> acc
    end)
  end


  def validate_type(%Cs{} = cs, field_name, type) when is_atom(type) do
    value = do_get_value(cs, field_name)
    case do_validate_types([type], value) do
      :ok ->
        cs
      {:error, _} ->
        put_error(cs, {field_name, Types.error_message_by_type(type)})
    end
  end

  def validate_type(%Cs{} = cs, field_name, types) when is_atom(field_name) and is_list(types) do
    value = do_get_value(cs, field_name)
    case do_validate_types(types, value) do
      :ok ->
        cs
      {:error, :none_of_types} ->
        put_error(cs, {field_name, :invalid_type})
    end
  end
  def validate_type(%Cs{module: module} = cs, typed_fields) when is_list(typed_fields) do
    type_tuples(module, typed_fields)
    |> Enum.reduce(cs, fn
      ({field_name, typing}, acc_cs) when is_atom(typing) or is_list(typing) ->
        validate_type(acc_cs, field_name, typing)
    end)
  end

  defp do_get_value(%Cs{model: model, changes: changes}, key) do
    if Map.has_key?(changes, key) do
      Map.get(changes, key)
    else
      Map.get(model, key)
    end
  end

  defp do_validate_types(types, value) do
    if Types.is_any_of?(types, value) do
      :ok
    else
      {:error, :none_of_types}
    end
  end

  defp type_tuples(module, types_list) do
    types_list
    |> Enum.map(fn
      key when is_atom(key) ->
        {key, retrieve_field_type(module, key)}
      {key, type} when is_atom(key) and is_atom(type) -> 
        {key, type}
      {key, types} when is_atom(key) and is_list(types) ->
        {key, types}
    end)
  end
  defp retrieve_field_type(module, key) do
    case Vertex.get_field(module, key) do
      nil ->
        err = "Could not find DgraphEx.Field for key #{inspect key} in module #{inspect module}"
        raise %ArgumentError{message: err}
      %Field{type: type} ->
        type
    end
  end

end