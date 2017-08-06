defmodule DgraphEx.Query.Block do
  alias DgraphEx.Query.Block

  defstruct [
    label: nil,
    keywords: [],
  ]

  defmacro __using__(_) do
    quote do
      def block(label, args) when is_atom(label) and is_list(args) do
        DgraphEx.Query.Block.new(label, args)
      end
      def block(label, args) when is_list(args) do
        DgraphEx.Query.Block.new(args)
      end
    end
  end


  def new(kwargs) when length(kwargs) >= 2 do
    %Block{
      keywords: kwargs,
    }
  end
  def new(label, kwargs) when is_atom(label) when length(kwargs) >= 2 do
    %Block{
      label: label,
      keywords: kwargs,
    }
  end

  def render(%Block{label: label} = b) do
    "#{label}("<> render_keywords(b) <>")"
  end
  def render(block) when is_tuple(block) do
    block
    |> Tuple.to_list
    |> render
  end
  def render(block) when is_list(block) do
    do_render(block, [])
  end

  defp render_keywords(%Block{keywords: keywords}) do
    keywords
    |> Enum.map(fn
      {key, %{__struct__: module} = model} when is_atom(key) -> "#{key}: #{module.render(model)}"
    end)
    |> Enum.join(", ")
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
  #[[genres: [%DgraphEx.Query.Block{keywords: [orderdesc: %DgraphEx.Expr.Val{label: :C}], label: :genre}, [genre_name: :name@en]]]]
  defp do_render([[ %{__struct__: module} = model | rest_keywords ] | rest ], lines) do
    do_render([ rest_keywords | rest], [ module.render(model) | lines ])
  end
  defp do_render([[{key, value}| rest_keywords ] | rest ], lines) when is_atom(key) and is_list(value) do
    do_render([rest_keywords | rest], ["#{key}: #{do_render(value, [])}"| lines])
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