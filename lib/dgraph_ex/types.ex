defmodule DgraphEx.Types do

  @types [
    :geo,
    :datetime,
    :date,
    :int,
    :float,
    :string,
    :bool,
    :uid,
  ]


  @doc """
  Examples:
    
    iex> DgraphEx.Types.validate(:geo, [1.0, 0.1])
    :ok

    iex> DgraphEx.Types.validate(:geo, [[[1.0, 0.1], [1.0, 0.2], [1.1, 0.2], [1.0, 0.1]]])
    :ok

    iex> DgraphEx.Types.validate(:geo, nil)
    {:error, :invalid_geo}
  
  """
  def validate(type, nil) do
    {:error, error_message_by_type(type)}
  end
  def validate(:geo, item) do
    case item do
      [x,y] when is_float(x) and is_float(y) ->
        :ok
      coords when is_list(coords) ->
        is_valid_geo_coords = 
          coords
          |> Enum.map(fn point -> validate(:geo, point) end)
          |> Enum.all?(fn item -> item == :ok end)
        if is_valid_geo_coords do
          :ok
        else
          {:error, error_message_by_type(:geo)}
        end
      _ ->
        {:error, error_message_by_type(:geo)}
    end
  end
  def validate(:datetime, item) do
    case item do
      %DateTime{} -> :ok
      _ -> {:error, error_message_by_type(:datetime)}
    end
  end
  def validate(:date, item) do
    case item do
      %Date{} -> :ok
      _ -> {:error, error_message_by_type(:date)}
    end
  end
  def validate(type, item) do
    case {type, item} do
      {:int,    x} when is_integer(x) -> :ok 
      {:float,  x} when is_float(x)   -> :ok
      {:string, x} when is_binary(x)  -> :ok
      {:bool,   x} when is_boolean(x) -> :ok
      {:uid,    x} when is_binary(x)  -> :ok
      _ -> {:error, error_message_by_type(type)}
    end
  end
  
  def error_message_by_type(type) when type in @types do
    # be very careful here.
    # We are going to construct an atom.
    # NEVER EVER remove the `when type in @types` guard or you may kill the erlang VM.
    String.to_atom("invalid_#{type}")
  end
  def error_message_by_type(nonexistent_type) do
    {:nonexistent_type, nonexistent_type}
  end

  @doc """
  Examples:
    
    iex> DgraphEx.Types.is_any_of?([:int, :string], "Beef")
    true

    iex> DgraphEx.Types.is_any_of?([:float, :int], "Beef")
    false

  """
  def is_any_of?(types, value) when is_list(types) do
    types
    |> Enum.map(fn type -> validate(type, value) end)
    |> Enum.any?(fn err -> err == :ok end)
  end

end