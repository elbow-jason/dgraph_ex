defmodule DgraphEx.Alter do
  alias DgraphEx.{Alter, Field}

  defstruct [
    fields: []
  ]

  defmacro __using__(_) do
    quote do

      def alter([%DgraphEx.Field{} | _] = fields) do
        fields
        |> DgraphEx.Alter.new()
      end
      def alter(module) do
        if !DgraphEx.Vertex.is_model?(module) do
          raise %ArgumentError{
            message: "DgraphEx.alter/1 only responds to Vertex models. #{module} does not use DgraphEx.Vertex"
          }
        end
        module.__vertex__(:fields)
        |> DgraphEx.Alter.new()
      end

    end
  end

  @doc """
  A static string that is the http path for altering a schema.

      iex> DgraphEx.Alter.path
      "/alter"
  """
  def path do
    "/alter"
  end

  @doc """
  Returns a DgraphEx.Alter struct with the given fields. default [].

      iex> DgraphEx.Alter.new
      %DgraphEx.Alter{fields: []}

      iex> DgraphEx.Alter.new([%DgraphEx.Field{predicate: :name}])
      %DgraphEx.Alter{fields: [%DgraphEx.Field{predicate: :name}]}
  """
  def new(fields \\ []) when is_list(fields) do
    %Alter{fields: fields}
  end

  @doc """
  Appends a Field struct to the fields (uh...) field of the alter struct.

      iex> DgraphEx.Alter.new() |> DgraphEx.Alter.append(%DgraphEx.Field{predicate: :name})
      %DgraphEx.Alter{fields: [%DgraphEx.Field{predicate: :name}]}
  """
  def append(%Alter{} = model, %Field{} = field) do
    %{ model | fields: model.fields ++ [field] }
  end


  @doc """
  Renders
  """
  def render(%__MODULE__{fields: fields}) do
    fields
    |> Enum.map(fn field -> Field.as_schema(field) end)
    |> Enum.join("\n")
  end

end