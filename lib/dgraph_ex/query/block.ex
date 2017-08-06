defmodule DgraphEx.Query.Block do
  
  def render(block) when is_tuple(block) do
    block
    |> Tuple.to_list
    |> do_render([])
  end

  defp do_render([], []) do
    "{ }"
  end
  defp do_render([], lines) do
    lines
    |> Enum.reverse
    |> Enum.join("\n")
    |> wrap_curlies
  end

  defp do_render([[] | rest], lines) do
    # empty keywords (might still be something left?)
    do_render(rest, lines)
  end
  defp do_render([[{key, value}| rest_keywords ] | rest ], lines) when is_atom(key) and (is_atom(value) or is_binary(value)) do
    # for keywords with stringy values
    do_render([rest_keywords | rest], ["#{key}: #{value}"| lines])
  end
  defp do_render([[{key, %{__struct__: module} = model} | rest_keywords ] | rest ], lines) when is_atom(key) do
    # for keywords with expr values
    do_render([rest_keywords | rest], ["#{key}: #{module.render(model)}"| lines])
  end
  defp do_render([%{__struct__: module} = model | rest ], lines) do
    # for exprs
    do_render(rest, [ module.render(model) | lines ])
  end 
  defp do_render([variable, :as, %{__struct__: module} = model | rest ], lines) when is_atom(variable) do
    # for aliases
    do_render(rest, ["#{variable} as #{module.render(model)}" | lines ])
  end
  defp do_render([new_block | rest], lines) when is_tuple(new_block) do
    # for new blocks or sub-blocks
    do_render(rest, [render(new_block) | lines])
  end
  defp do_render([variable | rest], lines) when is_atom(variable) do
    # for normal fields
    do_render(rest, [ to_string(variable) | lines ])
  end

  defp wrap_curlies(block) do
    "{\n"<>block<>"\n}"
  end
end