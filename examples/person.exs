defmodule DgraphEx.Examples.Person do
  use DgraphEx.Vertex

  alias DgraphEx.Vertex
  alias DgraphEx.Examples.Person

  vertex do
    field :name,    :string, index: [:exact, :term]
    field :address, :string, index: [:exact, :term]
  end

  def schema do
    Person
    |> Vertex.schema
  end

  def write_schema do
    schema()
    |> Vertex.mutation
    |> DgraphEx.query()
  end

  def put_person(name, age, ""<>dob) do
    {:ok, dob} = Date.from_iso8601(dob)
    put_person(name, age, dob)
  end
  def put_person(""<>name, age, %Date{} = dob) when is_integer(age) do
    tmpl = """
    mutation {
      set {
        _:person <name> $name" .
        _:person <age> $age .
        _:person <date_of_birth> $dob .
      }
    }
    """
    vars = %{
      name: {name, :string},
      age: {age, :int},
      dob: {dob, :datetime},
    }
    DgraphEx.query(tmpl, vars)
  end


  @doc """
  Assuming we want adult persons
  """
  def get_adults do

  end

end
