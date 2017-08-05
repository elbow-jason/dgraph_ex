defmodule DgraphEx.Template do
    alias DgraphEx.Template

  defstruct [:query, :variables]

  def prepare(query, vars) when is_map(vars) do
    vars
    |> Enum.into([])
    |> Enum.map(fn {name, {value, type}} -> {name, value, type} end)
    |> prepare(query)
  end
  def prepare(query, vars) when is_list(vars) and is_binary(query) do
    vars =
      vars
      |> Enum.map(fn {name, value, type} -> {name |> dollarify, to_string(value), to_string(type)} end)
    args =
      vars
      |> Enum.map(fn {name, _, type} -> name <> ": " <> type end)
      |> Enum.join(", ")
    var_map =
      vars
      |> Enum.map(fn {name, value, _type} -> {name, value} end)
      |> Enum.into(%{})
    %Template{
      query: "query me(" <> args <> ")" <> query,
      variables: var_map
    }
  end

  defp dollarify("$" <> item) do
    dollarify(item)
  end
  defp dollarify("" <> item) do
    "$" <> item
  end
  defp dollarify(item) do
    item
    |> to_string
    |> dollarify
  end

end
