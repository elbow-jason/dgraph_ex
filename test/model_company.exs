defmodule DgraphEx.ModelCompany do
  use DgraphEx.Vertex
  alias DgraphEx.ModelCompany, as: Company
  alias DgraphEx.ModelPerson, as: Person
  alias DgraphEx.Changeset
  

  vertex :company do
    field :name,      :string, index: [:exact, :terms]
    field :owner,     :uid, model: Person, reverse: true
    field :location,  :geo, index: true
  end

  @allowed_fields [
    :name,
    :owner,
    :location,
  ]

  def changeset(%Company{} = model, %{} = changes) do
    model
    |> Changeset.cast(changes, @allowed_fields)
    |> Changeset.validate_required([:name])
    |> Changeset.validate_type([:name])
  end

end