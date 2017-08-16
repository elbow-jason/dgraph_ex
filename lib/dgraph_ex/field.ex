defmodule DgraphEx.Field do
  alias DgraphEx.{Field, Vertex, Expr}
  alias Expr.{Uid}

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
    :string,
    :datetime,
    :date,
    :int,
    :bool,
    :float,
    :password,
    :geo,
    :uid,
  ]


  @doc """
  This macro is for use inside vertex/2 macro blocks (for field definitions).
  """
  defmacro field(predicate, type, options \\ []) do
    quote do
      alias DgraphEx.{Field}
      field = Field.new(unquote(predicate), unquote(type), unquote(options))
      Module.put_attribute(__MODULE__, :vertex_fields, field)
    end
  end

  defmacro __using__(_) do
    quote do
      alias DgraphEx.{Query, Field, Mutation}
      def field(%Mutation{sequence: [ first | rest ]} = m, subject, predicate, object, type) do
        new_field = 
          Field.new(predicate, type)
          |> Field.put_subject(subject)
          |> Field.put_object(object)
        first = %{ first | fields: [ new_field | first.fields ] }
        %{ m | sequence: [ first | rest ]}
      end
      def field(%Query{} = q, subject, predicate, object, type) do
        new_field = 
          Field.new(predicate, type)
          |> Field.put_subject(subject)
          |> Field.put_object(object)
        Query.put_sequence(q, new_field)
      end

      def field(predicate, type, options \\ [])
      def field(predicate, type, options) when is_atom(predicate) and is_atom(type) and is_list(options) do
        Field.new(predicate, type, options)
      end

      def field(subject, predicate, object) when subject == "*"   and is_atom(predicate)
                                            when is_atom(subject) and predicate == "*"
                                            when is_atom(subject) and is_atom(predicate)
                                            when subject == "*"   and predicate == "*" do
        Field.delete_field(subject, predicate, object)
      end
      def field(%Uid{} = subject, predicate, object) when is_atom(predicate)
                                                     when predicate == "*" do
        Field.delete_field(subject, predicate, object)
      end


    end
  end

  def new(predicate, type, options \\ []) when is_atom(predicate) and type in @allowed_types and is_list(options) do
    %Field{
      predicate:  predicate,
      type:       type,
      index:      options[:index],
      facets:     options[:facets],
      count:      !!options[:count],
      default:    options[:default],
      virtual:    !!options[:virtual],
      reverse:    !!options[:reverse],
      model:      options[:model],
    }
  end

  def delete_field(subject, predicate, object) do
    %Field{
      subject:    subject,
      predicate:  predicate,
      object:     object,
    }
  end

  def put_subject(fields, subject) when is_list(fields) do
    fields
    |> Enum.map(fn f -> put_subject(f, subject) end)
  end
  def put_subject(%Field{} = field, subject) when is_atom(subject) do
    %{ field | subject: subject }
  end
  def put_subject(fields, subject) when is_list(fields) do
    fields
    |> Enum.map(fn f -> put_subject(f, subject) end)
  end
  def put_subject(%Field{} = field, %Uid{} = subject) do
    %{ field | subject: subject }
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
  def put_object(%Field{type: :uid} = field, %{__struct__: _} = model) do
    do_put_object(field, model)
  end
  def put_object(%Field{type: :uid_literal} = field, %Uid{} = uid) do
    do_put_object(field, uid |> Uid.as_literal)
  end
  def put_object(%Field{type: :uid_literal} = field, ""<>uid) do
    do_put_object(field, uid |> Uid.new |> Uid.as_literal)
  end



  defp do_put_object(field, value) do
    %{ field | object: value }
  end


  def as_setter(%Field{object: nil}) do
    ""
  end
  def as_setter(%Field{type: :uid, predicate: child_subject, object: %{__struct__: _} = model} = f) do
    child_fields =
      child_subject
      |> Vertex.populate_fields(model)
      |> Enum.map(&as_setter/1)
    [ as_setter(%{f | object: child_subject }) | child_fields ]
  end
  def as_setter(%Field{type: :uid, object: obj} = f) when is_atom(obj) do
    [
      render_setter_subject(f), 
      render_setter_predicate(f),
      "_:#{obj}",
      render_facets(f),
      ".",
    ]
    |> filter_empty
    |> Enum.join(" ")
  end
  def as_setter(%Field{object: object} = f) when not is_nil(object) do
    type_anno = type_annotation(f.type)
    [
      render_setter_subject(f), 
      render_setter_predicate(f),
      (object |> stringify |> wrap_quotes)<>type_anno,
      render_facets(f),
      "."
    ]
    |> filter_empty
    |> Enum.join(" ")
  end

  defp render_setter_subject(%Field{subject: subject}) when is_atom(subject) do
    "_:#{subject}"
  end
  defp render_setter_subject(%Field{subject: %Uid{} = subject}) do
    subject |> Uid.render
  end

  defp render_setter_predicate(%Field{predicate: predicate}) do
    "<" <> to_string(predicate) <> ">"
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

  def as_schema(%Field{predicate: :_uid_}) do
    nil
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

  def as_delete(%Field{subject: subject, predicate: pred, object: object}) do
    [
      render_delete_subject(subject),
      render_delete_pred(pred),
      render_delete_object(object),
      "."
    ]
    |> filter_empty
    |> Enum.join(" ")
  end

  defp render_delete_subject("*") do
    "*"
  end
  defp render_delete_subject(%Uid{} = uid) do
    uid |> Uid.as_literal |> Uid.render
  end

  defp render_delete_pred("*") do
    "*"
  end
  defp render_delete_pred(pred) do
    "<"<>to_string(pred)<>">"
  end

  defp render_delete_object("*") do
    "*"
  end
  defp render_delete_object(""<>object) do
    wrap_quotes(object)
  end
  defp render_delete_object(something) do
    to_string(something)
  end


  def dollarify(%Field{} = f) do
     dollarify(to_string(f.subject) <> "_" <> to_string(f.predicate))
  end
  def dollarify(item) do
    "$" <> to_string(item)
  end

  def stringify(value) do
    case value do
      x when is_list(x) -> x |> Poison.encode!
      %Date{} = x       -> x |> Date.to_iso8601 |> Kernel.<>("T00:00:00.0+00:00")
      %DateTime{} = x   -> x |> DateTime.to_iso8601 |> String.replace("Z", "+00:00")
      x                 -> x |> to_string
    end
  end

  defp render_index(%Field{index: true, type: type}) do
    "@index(#{type})"
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
      :uid      -> ""
    end
  end

  def wrap_quotes(item) do
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

