defmodule DgraphEx.Query.Block do
  alias DgraphEx.Query.Block
  alias DgraphEx.Query
  alias DgraphEx.Expr.Uid

  defstruct [
    label: nil,
    keywords: [],
    aliased: nil,
  ]

  #as per @srh on dgraph slack (there may be more than these) v0.8.0
  @keyword_keys ~w(func orderasc orderdesc first after offset)a

  def keyword_allowed_keys() do
    @keyword_keys
  end

  defmacro __using__(_) do
    quote do
      alias DgraphEx.Query
      alias Query.{Block}
      def func(%Query{} = q, label, %{__struct__: _} = expr) do
        b = Block.new(label, [func: expr])
        Query.put_sequence(q, b)
      end
      def func(label, %{__struct__: _} = expr) do
        Block.new(label, [func: expr])
      end
      
      def block(label, args) when is_atom(label) and is_list(args) do
        Block.new(label, args)
      end
      def block(args) when is_list(args) do
        Block.new(args)
      end

      def block(%Query{} = q, args) when is_list(args) do
        Query.put_sequence(q, Block.new(args))
      end
      def block(%Query{} = q, label, args) do
        Query.put_sequence(q, Block.new(label, args))
      end
      def aliased(label, value) when is_atom(label) do
        Block.aliased(label, value)
      end
    end
  end

  def new(kwargs) when is_list(kwargs) do
    %Block{
      keywords: kwargs,
    }
  end
  def new(label, kwargs) when is_atom(label) and is_list(kwargs) do
    %Block{
      label: label,
      keywords: kwargs,
    }
  end
  def aliased(key, val) do
    %Block{
      aliased: {key, val}
    }
  end

  def put_kwarg(%Block{} = b, {k, v}) do
    put_kwarg(b, k, v)
  end
  def put_kwarg(%Block{keywords: kw} = b, key, value) do
    %{ b | keywords: kw ++ [{key, value}] }
  end

  def render(%Block{aliased: {key, %{__struct__: module} = model}}) do
    "#{key}: #{module.render(model)}"
  end
  def render(%Block{aliased: {key, value}}) do
    "#{key}: #{value}"
  end
  def render(%Block{label: label} = b) do
    "#{label}("<> render_keywords(b) <>")"
  end
  def render(block) when is_tuple(block) do
    block
    |> Tuple.to_list
    |> do_render([])
  end

  defp render_keywords(%Block{keywords: keywords}) do
    keywords
    # |> Enum.reverse
    |> Enum.map(fn
      {key, %{__struct__: module} = model} when is_atom(key) ->
        {key, model} = prepare_expr({key, model})
        {key, module.render(model)}
      {key, value} when is_atom(value) or is_number(value) ->
        {key, to_string(value)}
    end)
    |> Enum.map(fn {k, v} -> to_string(k)<>": "<>v end)
    |> Enum.join(", ")
  end

  def prepare_expr(expr) do
    case expr do
      {:func, %Uid{} = uid} ->
        {:func, Uid.as_expression(uid)}
      %Uid{} -> expr |> Uid.as_naked
      _ -> expr
    end
  end

  defp do_render([], []) do
    "{ }"
  end
  defp do_render([], lines) do
    lines
    |> Enum.reverse
    |> Enum.join(" ")
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
    "{ "<>block<>" }"
  end
end