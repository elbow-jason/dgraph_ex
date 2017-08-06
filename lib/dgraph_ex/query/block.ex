defmodule DgraphEx.Query.Block do
  
  def render(block) when is_tuple(block) do
    block
    |> Tuple.to_list
    |> List.flatten
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

  defp do_render([%{__struct__: module} = model | rest ], lines) do
    do_render(rest, [ module.render(model) | lines ])
  end 
  defp do_render([variable, :as, %{__struct__: module} = model | rest ], lines) when is_atom(variable) do
    do_render(rest, ["#{variable} as #{module.render(model)}" | lines ])
  end
  defp do_render([{key, value} | rest], lines) when is_atom(key) and is_atom(value) do
    do_render(rest, ["#{key}: #{value}"| lines])
  end
  defp do_render([{key, %{__struct__: module} = model} | rest], lines) when is_atom(key) do
    do_render(rest, ["#{key}: #{module.render(model)}" | lines ])
  end
  defp do_render([new_block | rest], lines) when is_tuple(new_block) do
    do_render(rest, [render(new_block) | lines])
  end
  defp do_render([variable | rest], lines) when is_atom(variable) do
    do_render(rest, [ to_string(variable) | lines ])
  end
  defp wrap_curlies(block) do
    "{\n"<>block<>"\n}"
  end
end