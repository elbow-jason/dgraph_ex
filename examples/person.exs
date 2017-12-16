defmodule DgraphEx.Examples.Person do
  use DgraphEx.Vertex

  alias DgraphEx.Examples.Person
  alias DgraphEx.Changeset

  vertex :person do
    field :name,    :string, index: [:exact, :term]
    field :address, :string, index: [:exact, :term]
  end

  def changeset(%Person{} = model, changes) when is_map(changes) do
    model
    |> Changeset.cast(changes, _allowed_fields = [:name, :address])
    |> Changeset.validate_required(_required_fields = [:name, :address])
    |> Changeset.validate_type(_typed_fields = [:name, :address])
    |> Changeset.uncast
  end

  def jason_g do

    person = 
      %Person{
        name: "Jason Goldberger",
        address: "123 Maple Rd Phoenix, AZ 85255"
      }
    rendered =
      DgraphEx.new
      |> DgraphEx.mutation
      |> DgraphEx.set
      |> DgraphEx.model(:person, person)
      |> DgraphEx.assemble
      |> DgraphEx.render

    IO.puts("rendered: #{rendered}")
    result = DgraphEx.Client.send(body: rendered)
    
    IO.puts("result: #{inspect result}")
    result
  end

  def billy_w do
    rendered =
      DgraphEx.new
      |> DgraphEx.mutation
      |> DgraphEx.set
      |> DgraphEx.field(:person, :name, "Bill Wiggins", :string)
      |> DgraphEx.field(:person, :address, "123 Oak St. Scottsdale, AZ 85251", :string)
      |> DgraphEx.assemble
      |> DgraphEx.render
    
    IO.puts("rendered: #{rendered}")
    result =
      rendered
      |> DgraphEx.Client.send
    
    IO.puts("result: #{inspect result}")
    result
  end
end
