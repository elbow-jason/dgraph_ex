defmodule DgraphEx.Field do
  alias DgraphEx.Field

  defstruct [
    :subject,
    :predicate,
    :object,
    :label,
    :facets,
    :index,
    :type,
    :count,
    :default,
    :virtual,
    :reverse,
    :model,
  ]

  @allowed_types [
    :string
    :datetime
    :date
    :int
    :bool
    :float
    :password
    :geo
  ]

  defmacro field(predicate, type, options \\ []) when type in @allowed_types do
    quote do
      options = unquote(options)
      facets = options[:facets]
      indices = options[:index]
      count = !!options[:count]
      default = options[:default]
      virtual = !!options[:virtual]
      reverse = !!options[:reverse]
      model = options[:model]
      field = %Field{
        predicate: unquote(predicate),
        type: unquote(type),
        index: indices,
        facets: facets,
        count: count,
        default: default,
        virtual: virtual,
        model: model,
      }
      Module.put_attribute(__MODULE__, :vertex_fields, field)
    end
  end

  def put_subject(fields, subject) when is_list(fields) do
    fields
    |> Enum.map(fn f -> put_subject(f, subject) end)
  end
  def put_subject(%Field{} = field, subject) when is_atom(subject) or is_binary(subject) do
    %{ field | subject: to_string(subject) }
  end

  def put_object(%Field{type: :int} = field, value) do
    case value do
      x when is_integer(x) ->
        do_put_object(field, x)
      x when is_binary(x) ->
        do_put_object(field, x |> String.to_integer)
    end
  end
  def put_object(%Field{type: :string} = field, value) when is_binary(value) do
    do_put_object(field, value)
  end
  def put_object(%Field{type: :date} = field, value) do
    case value do
      %Date{} = date ->
        do_put_object(field, date)
      %DateTime{year: y, month: m, day: d} ->
        {:ok, date} = Date.new(y, m, d)
        do_put_object(field, date)
      x when is_binary(x) ->
        date = Date.from_iso8601!(x)
        do_put_object(field, date)
    end
  end
  def put_object(%Field{type: :datetime} = field, value) do
    case value do
      %DateTime{} = datetime ->
        do_put_object(field, datetime)
      x when is_binary(x) ->
        {:ok, datetime, _offset} = DateTime.from_iso8601(x)
        do_put_object(field, datetime)
    end
  end


  defp do_put_object(field, value) do
    %{ field | object: value }
  end


  def as_setter(%Field{object: nil}) do
    ""
  end
  def as_setter(%Field{object: object} = f) when not is_nil(object) do
    type_anno = type_annotation(f.type)
    [
      "_:#{f.subject}", 
      "<#{f.predicate}>",
      (object |> stringify |> wrap_quotes)<>type_anno,
      render_facets(f),
      "."
    ]
    |> filter_empty
    |> Enum.join(" ")
  end


  def as_setter_template(%Field{object: nil}) do
    ""
  end
  def as_setter_template(%Field{object: object} = f) when not is_nil(object) do
    [
      "_:#{f.subject}", 
      "<#{f.predicate}>",
      f.label,
      render_facets(f),
      "."
    ]
    |> filter_empty
    |> Enum.join(" ")
  end

  def as_variables(%Field{} = f) do
    {dollarify(f), f.object, f.type}
  end

  def as_schema(%Field{} = f) do
    [
      to_string(f.predicate) <> ":",
      to_string(f.type),
      render_index(f),
      render_count(f),
      render_reverse(f),
      ".",
    ]
    |> filter_empty
    |> Enum.join(" ")
  end

  def dollarify(%Field{} = f) do
    "$" <> to_string(f.subject) <> "_" <> to_string(f.predicate)
  end

  defp stringify(value) do
    case value do
      x when is_list(x) -> x |> Poison.encode!
      %Date{} = x       -> x |> Date.to_iso8601 |> Kernel.<>("T00:00:00.0+00:00")
      %DateTime{} = x   -> x |> DateTime.to_iso8601 |> String.replace("Z", "+00:00")
      x                 -> x |> to_string
    end
  end

  defp render_index(%Field{index: true}) do
    "@index"
  end
  defp render_index(%Field{index: indices}) when is_list(indices) do
    "@index("<> (indices |> Enum.map(&to_string/1) |> Enum.join(", ")) <>")"
  end
  defp render_index(%Field{index: nil}) do
    nil
  end

  defp render_count(%Field{count: true}) do
    "@count"
  end
  defp render_count(_) do
    nil
  end

  defp render_reverse(%Field{reverse: true}) do
    "@reverse"
  end
  defp render_reverse(_) do
    nil
  end

  defp filter_empty(items) do
    items
    |> Enum.filter(fn
      "" -> nil
      item -> item
    end)
  end

  def type_annotation(type) do
    case type do
      :string   -> "^^<xs:string>"
      :datetime -> "^^<xs:dateTime>"
      :date     -> "^^<xs:date>"
      :int      -> "^^<xs:int>"
      :bool     -> "^^<xs:boolean>"
      :float    -> "^^<xs:float>"
      :password -> "^^<pwd:password>"
      :geo      -> "^^<geo:geojson>"
    end
  end

  defp wrap_quotes(item) do
    "\"" <> item <> "\""
  end

  defp render_facets(%Field{facets: facets}) when facets in [[], nil] do
    ""
  end
  defp render_facets(%Field{facets: facets}) do
    case facets do
      nil ->
        ""
      %{} -> 
        facet_string =
          facets
          |> Enum.map(fn {k, v} -> "#{k}=#{stringify(v)}" end)
          |> Enum.join(",")
        " ("<>facet_string<>")"
    end
  end

end

