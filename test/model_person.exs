defmodule DgraphEx.ModelPerson do
  use DgraphEx.Vertex
  alias DgraphEx.ModelPerson, as: Person
  alias DgraphEx.ModelCompany, as: Company
  alias DgraphEx.Changeset

  vertex :person do
    field :name,      :string
    field :age,       :int
    field :works_at,  :uid, model: Company
    field :company_count, :int, virtual: true, resolve: "count(works_at)"
  end

  @allowed_fields [
    :name,
    :age,
    :works_at,
  ]

  def changeset(%Person{} = model, %{} = changes) do
    model
    |> Changeset.cast(changes, @allowed_fields)
    |> Changeset.validate_required([:name])
    |> Changeset.validate_type([:name, :age])
    # |> Changeset.validate_model(:works_at, Company, :changeset)
  end


end
