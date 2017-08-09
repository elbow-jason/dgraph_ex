defmodule DgraphEx.Util do
  alias DgraphEx.Expr.Uid

  def as_rendered(value) do
    case value do
      x when is_list(x) -> x |> Poison.encode!
      %Date{} = x       -> x |> Date.to_iso8601 |> Kernel.<>("T00:00:00.0+00:00")
      %DateTime{} = x   -> x |> DateTime.to_iso8601 |> String.replace("Z", "+00:00")
      x                 -> x |> to_string
    end
  end

  def infer_type(type) do
    case type do
      x when is_boolean(x)  -> :bool
      x when is_binary(x)   -> :string
      x when is_integer(x)  -> :int
      x when is_float(x)    -> :float
      x when is_list(x)     -> :geo
      %DateTime{}           -> :datetime
      %Date{}               -> :date
      %Uid{}                -> :uid
    end
  end

  def as_literal(value, type) do
    case {type, value} do
      {:int, v} when is_integer(v)      -> {:ok, to_string(v)}
      {:float, v} when is_float(v)      -> {:ok, as_rendered(v)}
      {:bool, v} when is_boolean(v)     -> {:ok, as_rendered(v)}
      {:string, v} when is_binary(v)    -> {:ok, v |> strip_quotes |> wrap_quotes}
      {:date, %Date{} = v}              -> {:ok, as_rendered(v)}
      {:datetime, %DateTime{} = v}      -> {:ok, as_rendered(v)}
      {:geo, v} when is_list(v)         -> check_and_render_geo_numbers(v)
      {:uid, v} when is_binary(v)       -> {:ok, "<"<>v<>">"}
      _ -> {:error, {:invalidly_typed_value, value, type}}
    end
  end

  def as_string(value) do
    value
    |> as_rendered
    |> strip_quotes
    |> wrap_quotes
  end

  defp check_and_render_geo_numbers(nums) do
    if nums |> List.flatten |> Enum.all?(&is_float/1) do
      {:ok, nums |> as_rendered}
    else
      {:error, :invalid_geo_json}
    end
  end

  defp wrap_quotes(value) when is_binary(value) do
    "\"" <> value <> "\""
  end

  defp strip_quotes(value) when is_binary(value) do
    value
    |> String.replace(~r/^"/, "")
    |> String.replace(~r/"&/, "")
  end


  def has_function(module, func, arity) do
    :erlang.function_exported(module, func, arity) 
  end

end